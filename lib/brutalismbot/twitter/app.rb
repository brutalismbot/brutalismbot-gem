require "twitter"

module Brutalismbot
  module Twitter
    class App
      ACCESS_TOKEN        = ENV["BRUTALISMBOT_TWITTER_ACCESS_TOKEN"]
      ACCESS_TOKEN_SECRET = ENV["BRUTALISMBOT_TWITTER_ACCESS_TOKEN_SECRET"]
      CONSUMER_KEY        = ENV["BRUTALISMBOT_TWITTER_CONSUMER_KEY"]
      CONSUMER_SECRET     = ENV["BRUTALISMBOT_TWITTER_CONSUMER_SECRET"]

      attr_reader :client

      def initialize(name, client = nil)
        @name   = name
        @client = client || ::Twitter::REST::Client.new(
          access_token:        ACCESS_TOKEN,
          access_token_secret: ACCESS_TOKEN_SECRET,
          consumer_key:        CONSUMER_KEY,
          consumer_secret:     CONSUMER_SECRET,
        )
      end

      def inspect
        "#<#{self.class}>"
      end

      def push(post, dryrun:nil)
        opts = {}
        updates, count = post.to_twitter.slice(:updates, :count).values
        updates.each_with_index do |update, i|
          Brutalismbot.logger.info("PUSH#{" [DRYRUN]" if dryrun} twitter://#{@name} [#{i + 1}/#{count}]")
          unless dryrun
            status = update[:status]
            media  = update[:media].map { |url| URI.open(url) }
            result = @client.update_with_media(status, media, opts)
            opts[:in_reply_to_status_id] = result.id
          end
        end
      end
    end
  end
end
