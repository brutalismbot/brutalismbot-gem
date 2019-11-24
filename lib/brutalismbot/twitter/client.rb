require "open-uri"
require "tempfile"

require "twitter"

require "brutalismbot/logger"

module Brutalismbot
  module Twitter
    class Client
      attr_reader :client

      def initialize(client:nil)
        @client = client || ::Twitter::REST::Client.new do |config|
          config.consumer_key    = ENV["TWITTER_CONSUMER_KEY"]
          config.consumer_secret = ENV["TWITTER_CONSUMER_SECRET"]
        end
      end

      def push(post, dryrun:nil)
        uri = URI.parse(post.url)
        Brutalismbot.logger.info("GET #{uri}")
        uri.open do |file|
          Brutalismbot.logger.info("PUSH #{"DRYRUN " if dryrun}twitter://@brutalismbot")
          @client.update_with_media(post.to_twitter, file) unless dryrun
        end
      end
    end
  end
end
