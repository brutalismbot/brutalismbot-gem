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
        opts = {}
        slices_for(post).each_with_index do |slice, index|
          status, media = slice
          Brutalismbot.logger.info("PUSH #{"DRYRUN " if dryrun}twitter://@brutalismbot")
          begin
            res = @client.update_with_media(status, media, opts)
            opts[:in_reply_to_status_id] = res.id
          rescue ::Twitter::Error::BadRequest => err
            if err.message =~ /Image file size must be <= \d+ bytes/
              Brutalismbot.logger.warn("IMAGE TOO LARGE - RETRYING WITH PREVIEWS")
              opts[:in_reply_to_status_id] = push_preview(post, opts, index)
            end
          end unless dryrun
        end
      end

      private

      def push_preview(post, opts, index)
        status, media = slices_for(post) do |i|
          i["p"].max {|a,b|  a["x"] * a["y"] <=> b["x"] * b["y"] }["u"]
        end.to_a[index]
        @client.update_with_media(status, media, opts).id
      end

      def slices_for(post, &block)
        status = status_for(post)
        media_urls = post.media_urls(&block)
        case media_urls.count % 4
        when 1 then media_urls.each_slice(3).to_a
        when 2 then media_urls.each_slice(3).to_a
        else media_urls.each_slice(4).to_a
        end.map do |media_urls_slice|
          media_urls_slice.map do |media_url|
            Brutalismbot.logger.info("GET #{media_url}")
            URI.open(media_url)
          end
        end.zip([status]).map(&:reverse)
      end

      def status_for(post)
        max = 280 - post.permalink.length - 1
        status = post.title.length <= max ? post.title : "#{post.title[0...max - 1]}…"
        status << "\n#{post.permalink}"
      end
    end
  end
end
