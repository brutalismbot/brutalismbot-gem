require "aws-sdk-s3"

require "brutalismbot/logger"
require "brutalismbot/s3/client"
require "brutalismbot/s3/prefix"
require "brutalismbot/reddit/post"

module Brutalismbot
  module Posts
    class Client < S3::Client
      def initialize(bucket:nil, prefix:nil, client:nil)
        bucket ||= ENV["POSTS_S3_BUCKET"] || "brutalismbot"
        prefix ||= ENV["POSTS_S3_PREFIX"] || "data/v1/posts/"
        super
      end

      def key_for(post)
        path = post.created_utc.strftime("year=%Y/month=%Y-%m/day=%Y-%m-%d/%s.json")
        File.join(@prefix, path)
      end

      def get(**options)
        super {|object| Reddit::Post.parse(object.body.read) }
      end

      def last
        Reddit::Post.parse(max_key.get.body.read)
      end

      def list(**options)
        super do |object|
          Brutalismbot.logger.info("GET s3://#{@bucket}/#{object.key}")
          Reddit::Post.parse(object.get.body.read)
        end
      end

      def max_key
        # Dig for max key
        prefix = Time.now.utc.strftime("#{@prefix}year=%Y/month=%Y-%m/day=%Y-%m-%d/")
        Brutalismbot.logger.info("GET s3://#{@bucket}/#{prefix}*")

        # Go up a level in prefix if no keys found
        until (keys = bucket.objects(prefix: prefix)).any? || prefix == @prefix
          prefix = prefix.split(/[^\/]+\/\z/).first
          Brutalismbot.logger.info("GET s3://#{@bucket}/#{prefix}*")
        end

        # Return max by key
        keys.max{|a,b| a.key <=> b.key }
      end

      def max_time
        max_key.key[/(\d+).json\z/, -1].to_i
      rescue NoMethodError
      end

      def push(post, dryrun:nil)
        key = key_for(post)
        Brutalismbot.logger.info("PUT #{"DRYRUN " if dryrun}s3://#{@bucket}/#{key}")
        @client.put_object(bucket: @bucket, key: key, body: post.to_json) unless dryrun
        {
          bucket: @bucket,
          key:    key,
          url:    post.permalink,
        }
      end
    end
  end
end
