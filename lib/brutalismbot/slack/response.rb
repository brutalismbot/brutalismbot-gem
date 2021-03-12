module Brutalismbot
  module Slack
    class Response
      def initialize(res)
        @res = res
      end

      def inspect
        "#<#{ self.class } #{ @res.code } #{ @res.message }>"
      end

      def body
        @res.body
      end

      def headers
        @res.each_header.sort.to_h
      end
    end
  end
end
