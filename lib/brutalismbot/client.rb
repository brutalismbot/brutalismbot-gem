require "brutalismbot/posts"
require "brutalismbot/reddit"
require "brutalismbot/slack"
require "brutalismbot/twitter"

module Brutalismbot
  class Client
    attr_reader :posts, :reddit, :slack, :twitter

    def initialize(posts:nil, reddit:nil, slack:nil, twitter:nil)
      @posts   = posts   || Posts::Client.new
      @reddit  = reddit  || Reddit::Client.new
      @slack   = slack   || Slack::Client.new
      @twitter = twitter || Twitter::Client.new
    end

    def pull(min_time:nil, max_time:nil, dryrun:nil)
      posts = @reddit.list(:new)
      posts = posts.select{|post| post.created_between?(min_time, max_time) }
      posts = posts.sort{|a,b| a.created_utc <=> b.created_utc }
      posts.map{|post| @posts.push(post, dryrun: dryrun) }
    end
  end
end
