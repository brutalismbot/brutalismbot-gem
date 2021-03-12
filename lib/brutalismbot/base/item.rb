require "json"

module Brutalismbot
  module Base
    class Item
      extend Parseable

      def initialize(data)
        @data = data
      end

      def inspect
        "#<#{ self.class }>"
      end

      def [](key)
        @data[key]
      end

      def to_h
        to_hash
      end

      def to_hash
        @data.to_h
      end

      def to_json
        to_hash.to_json
      end
    end
  end
end
