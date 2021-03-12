require "json"

require "brutalismbot/logging"

module Brutalismbot
  module Aws
    module S3
      class Object
        attr_reader :object, :bucket, :key

        def initialize(object)
          @object = object
          @bucket = @object.bucket
          @key    = @object.key
        end

        def inspect
          "#<#{ self.class } #{ @key }>"
        end

        def to_hash
          JSON.parse(to_json)
        end

        def to_json
          Brutalismbot.logger.info("GET s3://#{ @bucket.name }/#{ @key }")
          @object.get.body.read
        end
      end
    end
  end
end
