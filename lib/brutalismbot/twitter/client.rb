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

      def push(post, dryrun:nil)
        method = post.is_self? ? :push_text : :push_image
        send(method, post, dryrun: dryrun)
      end

      def push_text(post, dryrun:nil)
        Brutalismbot.logger.info("PUSH #{"DRYRUN " if dryrun}twitter://@brutalismbot")
        @client.update(post.to_twitter) unless dryrun
      end

      def push_image(post, dryrun:nil)
        Brutalismbot.logger.info("GET #{post.media_uri}")
        Brutalismbot.logger.info("PUSH #{"DRYRUN " if dryrun}twitter://@brutalismbot")
        post.media_uri.open do |media|
          @client.update_with_media(post.to_twitter, media)
        end unless dryrun
      end
    end
  end
end
