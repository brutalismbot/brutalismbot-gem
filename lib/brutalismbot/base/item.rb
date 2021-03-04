require "json"

module Brutalismbot
  module Base
    class Item
      def initialize(**item)
        @item = JSON.parse(item.to_json)
      end

      def inspect
        "#<#{self.class}>"
      end

      def to_h
        @item
      end

      def to_json
        @item.to_json
      end
    end
  end
end
