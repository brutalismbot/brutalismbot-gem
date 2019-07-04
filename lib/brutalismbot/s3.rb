require "aws-sdk-s3"

require "brutalismbot"

module Brutalismbot
  module S3
    class Prefix
      include Enumerable

      attr_reader :prefix, :client

      def initialize(bucket:nil, prefix:nil, client:nil)
        @bucket = bucket || "brutalismbot"
        @prefix = prefix || "data/v1/"
        @client = client || Aws::S3::Client.new
      end

      def each
        bucket.objects(prefix: @prefix).each{|x| yield x }
      end

      def all
        to_a
      end

      def bucket(options = {})
        options[:name]   ||= @bucket
        options[:client] ||= @client
        Aws::S3::Bucket.new options
      end

      def put(object)
        key = key_for object
        Brutalismbot.logger.info "PUT #{@client.config.stub_responses ? "DRYRUN ": ""}s3://#{@bucket}/#{key}"
        bucket.put_object key: key, body: object.to_json
      end

      def delete(object)
        key = key_for object
        Brutalismbot.logger.info "DELETE #{@client.config.stub_responses ? "DRYRUN ": ""}s3://#{@bucket}/#{key}"
        bucket.object(key).delete
      end
    end

    class Client < Prefix
      def auths
        prefix = File.join @prefix, "auths/"
        AuthCollection.new bucket: @bucket, prefix: prefix, client: @client
      end

      def posts
        prefix = File.join @prefix, "posts/"
        PostCollection.new bucket: @bucket, prefix: prefix, client: @client
      end

      def subreddit(endpoint:nil, user_agent:nil)
        R::Brutalism.new endpoint:endpoint, user_agent: user_agent
      end
    end

    class AuthCollection < Prefix
      def each
        super{|x| yield Auth[JSON.parse x.get.body.read] }
      end

      def key_for(auth)
        File.join @prefix, "team=#{auth.team_id}/channel=#{auth.channel_id}/oauth.json"
      end

      def mirror(post, options = {})
        options[:body] = post.to_slack.to_json
        map{|x| x.post options }
      end
    end

    class PostCollection < Prefix
      def each
        super{|x| yield Post[JSON.parse x.get.body.read] }
      end

      def key_for(post)
        File.join @prefix, post.created_utc.strftime("year=%Y/month=%Y-%m/day=%Y-%m-%d/%s.json")
      end

      def last
        # Dig for max key
        prefix = Time.now.utc.strftime "#{@prefix}year=%Y/month=%Y-%m/day=%Y-%m-%d/"
        Brutalismbot.logger.info "GET s3://#{@bucket}/#{prefix}*"

        # Go up a level in prefix if no keys found
        until (keys = bucket.objects(prefix: prefix)).any?
          prefix = prefix.split(/[^\/]+\/\z/).first
          Brutalismbot.logger.info "GET s3://#{@bucket}/#{prefix}*"
        end

        # Get max by key
        max_key = keys.max{|a,b| a.key <=> b.key }

        # Parse as Post
        Post[JSON.parse max_key.get.body.read]
      end

      def pull(options = {})
        options[:before] ||= last.fullname
        R::Brutalism.new.posts(:new, options).reverse_each.map{|x| put x }
      end
    end

    class StubClient < Client
      def initialize(bucket:nil, prefix:nil, client:nil)
        client ||= Aws::S3::Client.new stub_responses: true
        super

        @auths = 3.times.map{ Auth.stub }
        @posts = 3.times.map{ Post.stub }.sort{|a,b| a.created_utc <=> b.created_utc }
        @client.stub_responses :list_objects, -> (context) { stub_list_objects context }
        @client.stub_responses :get_object,   -> (context) { stub_get_object context }
      end

      def stub_list_objects(context)
        {
          contents: if context.params[:prefix] =~ /auths\//
            @auths.map do |auth|
              File.join(
                @prefix,
                "auths",
                "team=#{auth.team_id}",
                "channel=#{auth.channel_id}",
                "oauth.json",
              )
            end
          elsif context.params[:prefix] =~ /posts\//
            @posts.map do |post|
              File.join(
                @prefix,
                "posts",
                post.created_utc.strftime("year=%Y/month=%Y-%m/day=%Y-%m-%d/%s.json"),
              )
            end
          end.select do |key|
            key.start_with? context.params[:prefix]
          end.map do |key|
            {
              key: key
            }
          end
        }
      end

      def stub_get_object(context)
        {
          body: if context.params[:key] =~ /auths\//
            @auths.select do |auth|
              File.join(
                @prefix,
                "auths",
                "team=#{auth.team_id}",
                "channel=#{auth.channel_id}",
                "oauth.json",
              ) == context.params[:key]
            end.first
          elsif context.params[:key] =~ /posts\//
            @posts.select do |post|
              File.join(
                @prefix,
                "posts",
                post.created_utc.strftime("year=%Y/month=%Y-%m/day=%Y-%m-%d/%s.json"),
              ) == context.params[:key]
            end.first
          end.to_json
        }
      end
    end
  end
end
