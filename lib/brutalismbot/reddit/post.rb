require "cgi"
require "forwardable"
require "open-uri"

require "brutalismbot/base/item"

module Brutalismbot
  module Reddit
    class Post < Base::Item
      def created_utc
        Time.at(data["created_utc"]&.to_f).utc
      rescue TypeError
      end

      def inspect
        "#<#{ self.class } name: #{ name }>"
      end

      def is_gallery?
        data["is_gallery"] || false
      end

      def is_self?
        data["is_self"] || false
      end

      def permalink
        File.join("https://www.reddit.com/", data["permalink"])
      end

      def title
        CGI.unescape_html(data["title"])
      rescue TypeError
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

      def name
        data["name"]
      end

      def to_slack
        {
          text: title,
          blocks: media_urls.map do |media_url|
            [
              {
                type: "image",
                title: {
                  type: "plain_text",
                  text: "/r/brutalism",
                  emoji: true,
                },
                image_url: media_url,
                alt_text: title,
              },
              {
                type: "context",
                elements: [
                  {
                    type: "mrkdwn",
                    text: "<#{ permalink }|#{ title }>",
                  },
                ],
              },
            ]
          end.flatten
        }
      end

      def to_twitter
        # Get status
        max    = 280 - permalink.length - 1
        status = title.length <= max ? title : "#{ title[0...max - 1] }…"
        status << "\n#{ permalink }"

        # Get media attachments
        media = media_urls.then do |urls|
          size = case urls.count % 4
          when 1 then 3
          when 2 then 3
          else 4
          end

          urls.each_slice(size)
        end

        # Zip status with media
        media.zip([status]).map do |media, status|
          { status: status, media: media}.compact
        end.then do |updates|
          { updates: updates, count: updates.count }
        end
      end

      private

      def data
        @data.fetch("data", {})
      end

      def preview_images
        @data.dig("data", "preview", "images")
      end

      def media_metadata
        @data.dig("data", "media_metadata")
      end

      ##
      # Get media URLs from gallery
      def media_urls_gallery
        media_metadata.values.map do |image|
          url = image.dig("s", "u")
          CGI.unescape_html(url) unless url.nil?
        end.compact
      end

      ##
      # Get media URLs from previews
      def media_urls_preview
        preview_images.map do |image|
          url = image.dig("source", "url")
          CGI.unescape_html(url) unless url.nil?
        end.compact
      end
    end
  end
end
