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
        status = status_for(post)
        media  = media_for(post)
        opts   = {}
        media.each_slice(4).zip(status).each do |post_media, post_status|
          Brutalismbot.logger.info("PUSH #{"DRYRUN " if dryrun}twitter://@brutalismbot")
          unless dryrun
            res = @client.update_with_media(post_status, post_media, **opts)
            opts[:in_reply_to_status_id] = res.id
          end
        end
      end

      private

      def status_for(post)
        max = 280 - post.permalink.length - 1
        status = post.title.length <= max ? post.title : "#{post.title[0...max - 1]}…"
        status << "\n#{post.permalink}"
        [status]
      end

      def media_for(post)
        post.media_urls.map do |media_url|
          Brutalismbot.logger.info("GET #{media_url}")
          URI.open(media_url)
        end
      end
    end
  end
end
