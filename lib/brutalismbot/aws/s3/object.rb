require "json"

require "brutalismbot/logger"

module Brutalismbot
  module Aws
    module S3
      class Object
        def initialize(object)
          @object = object
        end

        def inspect
          "#<#{ self.class } #{ @object.key }>"
        end

        def to_json
          Brutalismbot.logger.info("GET s3://#{ @object.bucket.name }/#{ @object.key }")
          JSON.parse(@object.get.body.read)
        end
      end
    end
  end
end
