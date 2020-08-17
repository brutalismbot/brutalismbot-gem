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
          config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
          config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
          config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
          config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
        end
      end

      def push(status:, media_url:nil, dryrun:nil)
        if media_url.nil?
          Brutalismbot.logger.info("PUSH #{"DRYRUN " if dryrun}twitter://@brutalismbot")
          @client.update(status) unless dryrun
        else
          Brutalismbot.logger.info("GET #{media_url}")
          Brutalismbot.logger.info("PUSH #{"DRYRUN " if dryrun}twitter://@brutalismbot")
          URI.open(media_url) {|media| @client.update_with_media(status, media) } unless dryrun
        end
      end
    end
  end
end
