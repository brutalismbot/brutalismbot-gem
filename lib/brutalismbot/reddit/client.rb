require "brutalismbot/version"
require "brutalismbot/logging"
require "brutalismbot/reddit/post"
require "brutalismbot/reddit/post_collection"
require "brutalismbot/reddit/queue"

module Brutalismbot
  module Reddit
    class Client
      ENDPOINT    = ENV["BRUTALISMBOT_REDDIT_ENDPOINT"]    || "https://www.reddit.com/r/brutalism/"
      USER_AGENT  = ENV["BRUTALISMBOT_REDDIT_USER_AGENT"]  || "Brutalismbot v#{ Brutalismbot::VERSION.split(/\./).first }"
      LAG_SECONDS = ENV["BRUTALISMBOT_REDDIT_LAG_SECONDS"] || 3 * 60 * 60

      def initialize(storage, endpoint = nil, user_agent = nil, lag_seconds = nil)
        @storage     = storage
        @endpoint    = endpoint    || ENDPOINT
        @user_agent  = user_agent  || USER_AGENT
        @lag_seconds = lag_seconds || LAG_SECONDS
      end

      def inspect
        "#<#{ self.class }>"
      end

      def posts
        PostCollection.new(@storage)
      end

      def queue
        Queue.new(@endpoint, @user_agent) do |listing|
          start = @storage.list_reddit_posts_created_utc.last || Time.at(0).utc
          stop  = Time.now.utc - @lag_seconds
          Brutalismbot.logger.info("BETWEEN (#{ start }...#{ stop })")
          listing.reject do |post|
            post.created_utc.then { |x| (nil..start) === x || (stop...) === x }
          end
        end
      end
    end
  end
end
