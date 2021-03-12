require "brutalismbot/reddit/listable"

module Brutalismbot
  module Reddit
    class Queue
      include Listable

      ENDPOINT    = ENV["BRUTALISMBOT_REDDIT_ENDPOINT"]    || "https://www.reddit.com/r/brutalism/"
      USER_AGENT  = ENV["BRUTALISMBOT_REDDIT_USER_AGENT"]  || "Brutalismbot v#{ Brutalismbot::VERSION[/\d+/] }"
      LAG_SECONDS = ENV["BRUTALISMBOT_REDDIT_LAG_SECONDS"] || 3 * 60 * 60

      def initialize(resource = :new, endpoint:nil, user_agent:nil, lag_seconds:nil)
        @endpoint = File.join(endpoint || ENDPOINT, "#{ resource }.json")
        @headers  = { "user-agent" => user_agent || USER_AGENT }
        @max_time = Time.now.utc - (lag_seconds || LAG_SECONDS)
        @filters  = []
        before(@max_time)
      end

      def each
        super { |post| post }.sort_by(&:created_utc).each do |post|
          yield post if @filters.reduce(true) { |memo, block| memo && post.then(&block) }
        end
      end

      def after(time)
        tap { @filters << -> (post) { post.created_utc > time } }
      end

      def before(time)
        tap { @filters << -> (post) { post.created_utc <= time } }
      end
    end
  end
end
