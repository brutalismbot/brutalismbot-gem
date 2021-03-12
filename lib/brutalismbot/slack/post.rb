require "brutalismbot/base/item"

module Brutalismbot
  module Slack
    class Post < Base::Item
      def inspect
        "#<#{ self.class } #{ text }>"
      end

      def blocks
        @data["blocks"]
      end

      def text
        @data["text"]
      end
    end
  end
end
