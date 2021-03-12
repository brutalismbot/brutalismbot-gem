require "brutalismbot/base/enumerable"

module Brutalismbot
  module Base
    class StorageCollection
      include Base::Enumerable

      attr_reader :storage

      def initialize(storage)
        @storage = storage
      end

      def each
        list.each { |item| yield item }
      end

      def <<(item)
        put(item).first
      end

      def delete(*items)
      end

      def get(key)
      end

      def list(**options)
      end

      def put(*items)
      end
    end
  end
end
