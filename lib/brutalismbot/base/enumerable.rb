module Brutalismbot
  module Base
    module Enumerable
      include ::Enumerable

      def inspect
        "#<#{ self.class }>"
      end

      def [](index)
        to_a[index]
      end

      def all
        to_a
      end

      def last
        to_a.last
      end

      def size
        count
      end
    end
  end
end
