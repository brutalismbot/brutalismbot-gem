module Brutalismbot
  module S3
    class Client
      VERSION = "v1"

      attr_reader :bucket, :prefix

      def initialize(bucket:, prefix:nil, **config)
        @bucket = bucket
        @prefix = prefix
        Brutalismbot.config.update config
      end

      def subreddit(endpoint:nil, user_agent:nil)
        Brutalismbot::R::Brutalism.new endpoint:   endpoint,
                                       user_agent: user_agent
      end

      def auths
        AuthCollection.new bucket: @bucket,
                           prefix: "#{@prefix}oauth/#{VERSION}/"
      end

      def posts
        PostCollection.new bucket: @bucket,
                           prefix: "#{@prefix}posts/#{VERSION}/"
      end
    end

    class Collection
      include Enumerable

      attr_reader :bucket, :prefix

      def initialize(bucket:, prefix:)
        @bucket = bucket
        @prefix = prefix
      end

      def each
        Brutalismbot.logger&.info "GET s3://#{@bucket.name}/#{@prefix}*"
        @bucket.objects(prefix: @prefix).each do |object|
          yield object
        end
      end

      def put(body:, key:, dryrun:nil)
        if dryrun
          Brutalismbot.logger&.info "PUT DRYRUN s3://#{@bucket.name}/#{key}"
        else
          Brutalismbot.logger&.info "PUT s3://#{@bucket.name}/#{key}"
          @bucket.put_object key: key, body: body
        end
      end
    end

    class AuthCollection < Collection
      def each
        super do |object|
          yield Brutalismbot::OAuth[JSON.parse object.get.body.read]
        end
      end

      def delete(team_id:, dryrun:nil)
        prefix = "#{@prefix}team=#{team_id}/"
        Brutalismbot.logger&.info "GET s3://#{@bucket.name}/#{prefix}*"
        @bucket.objects(prefix: prefix).map do |object|
          if dryrun
            Brutalismbot.logger&.info "DELETE DRYRUN s3://#{@bucket.name}/#{object.key}"
          else
            Brutalismbot.logger&.info "DELETE s3://#{@bucket.name}/#{object.key}"
            object.delete
          end
        end
      end

      def put(auth:, dryrun:nil)
        key = "#{@prefix}team=#{auth.team_id}/channel=#{auth.channel_id}/oauth.json"
        super key: key, body: auth.to_json, dryrun: dryrun
      end
    end

    class PostCollection < Collection
      def each
        super do |object|
          yield R::Brutalism::Post[JSON.parse object.get.body.read]
        end
      end

      def latest
        R::Brutalism::Post[JSON.parse max_key.get.body.read]
      end

      def max_key
        # Dig for max key
        prefix = prefix_for time: Time.now.utc
        Brutalismbot.logger&.info "GET s3://#{@bucket.name}/#{prefix}*"

        # Go up a level in prefix if no keys found
        until (keys = @bucket.objects(prefix: prefix)).any?
          prefix = prefix.split(/[^\/]+\/\z/).first
          Brutalismbot.logger&.info "GET s3://#{@bucket.name}/#{prefix}*"
        end

        # Return max by key
        keys.max{|a,b| a.key <=> b.key }
      end

      def max_time
        max_key.key.match(/(\d+).json\z/).to_a.last.to_i
      end

      def prefix_for(time:)
        time  = Time.at(time.to_i).utc
        year  = time.strftime '%Y'
        month = time.strftime '%Y-%m'
        day   = time.strftime '%Y-%m-%d'
        "#{@prefix}year=#{year}/month=#{month}/day=#{day}/"
      end

      def put(post:, dryrun:nil)
        key = "#{prefix_for time: post.created_utc}#{post.created_utc.to_i}.json"
        super key: key, body: post.to_json, dryrun: dryrun
      end
    end
  end
end
