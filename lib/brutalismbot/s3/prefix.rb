require "aws-sdk-s3"

require "brutalismbot/logger"

module Brutalismbot
  module S3
    class Prefix
      include Enumerable

      attr_reader :prefix, :client

      def initialize(bucket:nil, prefix:nil, client:nil, &block)
        @bucket = bucket || ENV["S3_BUCKET"] || "brutalismbot"
        @prefix = prefix || ENV["S3_PREFIX"] || "data/v1/"
        @client = client || Aws::S3::Client.new
        @block  = block if block_given?
      end

      def each
        Brutalismbot.logger.info("LIST s3://#{@bucket}/#{@prefix}*")
        bucket.objects(prefix: @prefix).each do |object|
          yield @block.nil? ? object : @block.call(object)
        end
      end

      def all
        to_a
      end

      def last
        to_a.last
      end

      def bucket(options = {})
        Aws::S3::Bucket.new({name: @bucket, client: @client}.merge(options))
      end
    end
  end
end
