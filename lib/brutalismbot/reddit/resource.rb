require "json"
require "net/http"

require "brutalismbot/logger"
require "brutalismbot/reddit/post"

module Brutalismbot
  module Reddit
    class Resource
      include Enumerable

      attr_reader :uri, :user_agent

      def initialize(uri:nil, user_agent:nil)
        @uri        = uri        || "https://www.reddit.com/r/brutalism/new.json"
        @user_agent = user_agent || "Brutalismbot v#{Brutalismbot::VERSION}"
      end

      def each
        Brutalismbot.logger.info("GET #{@uri}")
        uri = URI.parse(@uri)
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
          request  = Net::HTTP::Get.new(uri, "user-agent" => @user_agent)
          response = JSON.parse(http.request(request).body)
          children = response.dig("data", "children") || []
          children.each do |child|
            item = child.transform_keys(&:to_sym)
            post = Post.new(**item)
            unless post.is_self?
              Brutalismbot.logger.warn("NO MEDIA URLs for #{post.permalink}") if post.media_urls.empty?
              yield post
            end
          end
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
