require "forwardable"
require "json"
require "net/http"

require "brutalismbot/base"

module Brutalismbot
  module Reddit
    class Post < Base
      def created_after?(time = nil)
        time.nil? || created_utc.to_i > time.to_i
      end

      def created_before?(time = nil)
        time.nil? || created_utc.to_i < time.to_i
      end

      def created_between?(start, stop)
        created_after?(start) && created_before?(stop)
      end

      def created_utc
        Time.at(data["created_utc"].to_i).utc
      end

      def data
        @item.fetch("data", {})
      end

      def fullname
        "#{kind}_#{id}"
      end

      def id
        data["id"]
      end

      def inspect
        "#<#{self.class} #{data["permalink"]}>"
      end

      def is_gallery?
        data["is_gallery"] || false
      end

      def is_self?
        data["is_self"] || false
      end

      def kind
        @item["kind"]
      end

      def media_metadata
        data["media_metadata"]
      end

      def permalink
        "https://reddit.com#{data["permalink"]}"
      end

      def preview_images
        data.dig("preview", "images")
      end

      def title
        CGI.unescape_html(data["title"])
      end

      def url
        data["url"]
      end

      ##
      # Get media URLs for post
      def media_urls
        if is_gallery?
          media_urls_gallery
        elsif preview_images
          media_urls_preview
        else
          []
        end
      end

      ##
      # S3 path
      def path
        created_utc.strftime("year=%Y/month=%Y-%m/day=%Y-%m-%d/%s.json")
      end

      private

      ##
      # Get media URLs from gallery
      def media_urls_gallery
        media_metadata.values.map do |image|
          url = image.dig("s", "u")
          CGI.unescape_html(url)
        end
      end

      ##
      # Get media URLs from previews
      def media_urls_preview
        preview_images.map do |image|
          url = image.dig("source", "url")
          CGI.unescape_html(url)
        end
      end
    end
  end
end
