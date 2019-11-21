require "aws-sdk-s3"

require "brutalismbot/logger"
require "brutalismbot/s3"
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
        File.join(
          @prefix,
          post.created_utc.strftime("year=%Y/month=%Y-%m/day=%Y-%m-%d/%s.json")
        )
      end

      def list(options = {})
        options = {bucket: @bucket, prefix: @prefix, client: @client}.merge(options)
        S3::Prefix.new(options) do |object|
          Brutalismbot.logger.info("GET s3://#{@bucket}/#{object.key}")
          Reddit::Post.parse(object.get.body.read)
        end
      end

      def max_key
        # Dig for max key
        prefix = Time.now.utc.strftime("#{@prefix}year=%Y/month=%Y-%m/day=%Y-%m-%d/")
        Brutalismbot.logger.info("GET s3://#{@bucket}/#{prefix}*")

        # Go up a level in prefix if no keys found
        until (keys = bucket.objects(prefix: prefix)).any?
          prefix = prefix.split(/[^\/]+\/\z/).first
          Brutalismbot.logger.info("GET s3://#{@bucket}/#{prefix}*")
        end

        # Return max by key
        keys.max{|a,b| a.key <=> b.key }
      end

      def max_time
        max_key.key[/(\d+).json\z/, -1].to_i
      end

      def push(post, dryrun:nil)
        key = key_for(post)
        Brutalismbot.logger.info("PUT #{"DRYRUN " if dryrun}s3://#{@bucket}/#{key}")
        bucket.put_object(key: key, body: post.to_json) unless dryrun
      end
    end
  end
end
