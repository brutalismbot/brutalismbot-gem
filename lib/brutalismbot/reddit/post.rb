require "forwardable"
require "json"
require "net/http"

require "brutalismbot/base"

module Brutalismbot
  module Reddit
    class Post < Base
      def initialize(**item)
        @mime_type = item.delete(:mime_type)
        super
      end

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

      def is_self?
        data["is_self"]
      end

      def kind
        @item["kind"]
      end

      def media_uri
        URI.parse(media_url)
      end

      def media_url
        # Use URL if it's an image
        if mime_type.start_with?("image/")
          data["url"]

        # Extract preview image URL
        else
          images = data.dig("preview", "images") || {}
          source = images.map{|x| x["source"] }.compact.max do |a,b|
            a.slice("width", "height").values <=> b.slice("width", "height").values
          end
          CGI.unescape_html(source["url"])
        end
      end

      def mime_type
        @mime_type ||= begin
          uri = URI.parse(data["url"])
          ssl = uri.scheme == "https"
          Brutalismbot.logger.info("HEAD #{uri}")
          Net::HTTP.start(uri.host, uri.port, use_ssl: ssl) do |http|
            req = Net::HTTP::Head.new(uri)
            http.request(req)["Content-Type"]
          end
        end
      end

      def path
        created_utc.strftime("year=%Y/month=%Y-%m/day=%Y-%m-%d/%s.json")
      end

      def permalink
        "https://reddit.com#{data["permalink"]}"
      end

      def title
        CGI.unescapeHTML(data["title"])
      end

      def to_s3(bucket:nil, prefix:nil)
        bucket ||= ENV["POSTS_S3_BUCKET"] || "brutalismbot"
        prefix ||= ENV["POSTS_S3_PREFIX"] || "data/v1/posts/"
        {
          bucket: bucket,
          key: File.join(*[prefix, path].compact),
          body: to_json,
        }
      end

      def to_slack
        is_self? ? to_slack_text : to_slack_image
      end

      def to_slack_image
        {
          blocks: [
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
                  text: "<#{permalink}|#{title}>",
                },
              ],
            },
          ],
        }
      end

      def to_slack_text
        {
          blocks: [
            {
              type: "section",
              text: {
                type: "mrkdwn",
                text: "<#{permalink}|#{title}>",
              },
              accessory: {
                type: "image",
                image_url: "https://brutalismbot.com/logo-red-ppl.png",
                alt_text: "/r/brutalism",
              },
            },
          ],
        }
      end

      def to_twitter
        max = 280 - permalink.length - 1
        text = title.length <= max ? title : "#{title[0...max - 1]}…"
        [text, permalink].join("\n")
      end

      def url
        data["url"]
      end
    end
  end
end
