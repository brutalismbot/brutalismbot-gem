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

    def pull(limit:nil, min_time:nil, max_time:nil, min_age:nil, dryrun:nil)
      # Get time window for new posts
      min_age  ||= 9000
      min_time ||= @posts.max_time
      max_time ||= Time.now.utc.to_i - min_age.to_i

      # Get posts
      opts  = {q:"self:no AND nsfw:no", restrict_sr: true, sort: "new"}
      posts = @reddit.list(:search, **opts).all

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
      @slack.list.map(&:webhook_url).each do |webhook_url|
        @slack.push(post, webhook_url, dryrun: dryrun)
      end

      nil
    end
  end
end
