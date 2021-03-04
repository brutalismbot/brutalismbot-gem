require "json"

require "brutalismbot/logger"
require "brutalismbot/base/enumerable"
require "brutalismbot/aws/s3/object"

module Brutalismbot
  module Aws
    module S3
      class Prefix
        include Base::Enumerable

        def initialize(bucket, **options, &block)
          @bucket  = bucket
          @options = options
          @block   = block || -> (object) { object }
        end

        def inspect
          "#<#{ self.class } #{ @options[:prefix] }>"
        end

        def [](index)
          objects.to_a.slice(index)&.map { |object| Object.new(object).then(&@block) }
        end

        def each
          objects.each { |object| yield Object.new(object).then(&@block) }
        end

        def last
          objects.to_a.last&.then { |object| Object.new(object).then(&@block) }
        end

        private

        def objects
          Brutalismbot.logger.info("LIST s3://#{ @bucket.name }/#{ @options[:prefix] }*")
          @bucket.objects(**@options)
        end
      end
    end
  end
end
