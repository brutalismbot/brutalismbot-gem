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
  end
end
