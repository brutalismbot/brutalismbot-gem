require "aws-sdk-s3"

require "brutalismbot/logger"
require "brutalismbot/s3/client"

module Brutalismbot
  module S3
    class Prefix
      include Enumerable

      def initialize(prefix, &block)
        @prefix = prefix
        @block  = block if block_given?
      end

      def each
        @prefix.each do |object|
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
