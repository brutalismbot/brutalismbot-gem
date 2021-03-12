require "json"

require "brutalismbot/base/item"

module Brutalismbot
  module Aws
    module DynamoDB
      class Item < Base::Item
        def initialize(data)
          super(data.transform_keys(&:to_sym))
        end

        def created_utc
          Time.at(@data[:CREATED_UTC].to_i).utc
        end

        def to_hash
          @data[:DATA].to_h
        end
      end
    end
  end
end
