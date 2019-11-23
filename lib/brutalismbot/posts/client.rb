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
        File.join(@prefix, post.path)
      end

      def last
        Reddit::Post.parse(max_key.get.body.read)
      end

      def list(options = {})
        super(options) do |object|
          Brutalismbot.logger.info("GET s3://#{@bucket.name}/#{object.key}")
          Reddit::Post.parse(object.get.body.read)
        end
      end

      def max_key
        # Dig for max key
        prefix = Time.now.utc.strftime("#{@prefix}year=%Y/month=%Y-%m/day=%Y-%m-%d/")
        Brutalismbot.logger.info("GET s3://#{@bucket.name}/#{prefix}*")

        # Go up a level in prefix if no keys found
        until (keys = @bucket.objects(prefix: prefix)).any?
          prefix = prefix.split(/[^\/]+\/\z/).first
          Brutalismbot.logger.info("GET s3://#{@bucket.name}/#{prefix}*")
        end

        # Return max by key
        keys.max{|a,b| a.key <=> b.key }
      end

      def max_time
        max_key.key[/(\d+).json\z/, -1].to_i
      end

      def push(post, dryrun:nil)
        key = key_for(post)
        Brutalismbot.logger.info("PUT #{"DRYRUN " if dryrun}s3://#{@bucket.name}/#{key}")
        @bucket.put_object(key: key, body: post.to_json) unless dryrun
      end
    end
  end
end
