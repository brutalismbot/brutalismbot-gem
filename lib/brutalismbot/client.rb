require "brutalismbot/posts/client"
require "brutalismbot/reddit/client"
require "brutalismbot/slack/client"
require "brutalismbot/twitter/client"

module Brutalismbot
  class Client
    attr_reader :posts, :reddit, :slack, :twitter

    def initialize(posts:nil, reddit:nil, slack:nil, twitter:nil)
      @posts   = posts   ||   Posts::Client.new
      @reddit  = reddit  ||  Reddit::Client.new
      @slack   = slack   ||   Slack::Client.new
      @twitter = twitter || Twitter::Client.new
    end

    def lag_time
      lag = ENV["BRUTALISMBOT_LAG_TIME"].to_s
      lag.empty? ? 9000 : lag.to_i
    end

    def pull(limit:nil, min_time:nil, max_time:nil, dryrun:nil)
      # Get time window for new posts
      min_time ||= @posts.max_time
      max_time ||= Time.now.utc.to_i - lag_time

      # Get posts
      posts = @reddit.list(:new)

      # Filter, sort, and limit
      posts = posts.select{|post| post.created_between?(min_time, max_time) }
      posts = posts.sort{|a,b| a.created_utc <=> b.created_utc }
      posts = posts.slice(0, limit) unless limit.nil?

      # Persist posts
      posts.map{|post| @posts.push(post, dryrun: dryrun) }
    end

    def push(post, dryrun:nil)
      # Push to Twitter
      @twitter.push(post, dryrun: dryrun)

      # Push to Slack
      @slack.push(post, dryrun: dryrun)

      nil
    end
  end
end
