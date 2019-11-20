require "aws-sdk-s3"

require "brutalismbot/logger"
require "brutalismbot/s3/client"

module Brutalismbot
  module S3
    class Prefix < Client
      include Enumerable

      def initialize(bucket:nil, prefix:nil, client:nil, &block)
        @block = block if block_given?
        super
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
    end
  end
end
