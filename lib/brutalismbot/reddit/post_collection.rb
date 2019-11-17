require "net/http"

require "brutalismbot/reddit/post"

module Brutalismbot
  module Reddit
    class PostCollection
      include Enumerable

      def initialize(uri:, user_agent:)
        @uri        = uri
        @ssl        = uri.scheme == "https"
        @user_agent = user_agent
      end

      def each
        Brutalismbot.logger.info("GET #{@uri}")
        Net::HTTP.start(@uri.host, @uri.port, use_ssl: @ssl) do |http|
          request  = Net::HTTP::Get.new(@uri, "user-agent" => @user_agent)
          response = JSON.parse(http.request(request).body)
          children = response.dig("data", "children") || []
          children.each{|child| yield Post.new(child) }
        end
      end

      def all
        to_a
      end

      def last
        to_a.last
      end
    end
  end
end
