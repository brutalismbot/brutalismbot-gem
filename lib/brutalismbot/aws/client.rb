module Brutalismbot
  module Aws
    class Client
      attr_reader :client

      def initialize(client = nil)
        @client = client || default_client
      end

      def inspect
        "#<#{ self.class }>"
      end

      private

      def default_client
      end
    end
  end
end
