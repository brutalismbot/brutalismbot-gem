require "open-uri"
require "tempfile"

require "twitter"

require "brutalismbot/version"

module Brutalismbot
  module Twitter
    class Client
      attr_reader :client

      def initialize(client:nil)
        @client = client || ::Twitter::REST::Client.new do |config|
          config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
          config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
          config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
          config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
        end
      end

      def push(post)
        text = [post.title, post.permalink].join("\n")
        file = Tempfile.new
        begin
          open(post.url){|res| file.write(res.read) }
          file.rewind
          @client.update_with_media(text, file)
        ensure
          file.close
          file.unlink
        end
      end
    end
  end
end