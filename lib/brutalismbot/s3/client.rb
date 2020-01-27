require "aws-sdk-s3"

module Brutalismbot
  module S3
    class Client
      attr_reader :prefix, :client

      def initialize(bucket:nil, prefix:nil, client:nil)
        @client = client || Aws::S3::Client.new
        @bucket = bucket || ENV["S3_BUCKET"] || "brutalismbot"
        @prefix = prefix || ENV["S3_PREFIX"] || "data/v1/"
      end

      def bucket(**options)
        options[:name] ||= @bucket
        options[:client] ||= @client
        Aws::S3::Bucket.new(**options)
      end

      def get(key:, bucket:nil, **options, &block)
        bucket ||= @bucket
        Brutalismbot.logger.info("GET s3://#{@bucket}/#{key}")
        object = @client.get_object(bucket: bucket, key: key, **options)
        block_given? ? yield(object) : object
      end

      def keys(bucket:nil, prefix:nil, **options)
        bucket ||= @bucket
        prefix ||= @prefix
        Brutalismbot.logger.info("LIST s3://#{@bucket}/#{prefix}*")
        result = self.bucket(name: bucket).objects(prefix: prefix, **options)
        Prefix.new(result)
      end

      def list(bucket:nil, prefix:nil, **options, &block)
        result = keys(bucket: bucket, prefix: prefix, **options)
        Prefix.new(result, &block)
      end
    end
  end
end
