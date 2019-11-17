require "forwardable"
require "json"

require "brutalismbot/reddit/stub"

module Brutalismbot
  module Reddit
    class Post
      extend Forwardable
      extend Stub

      def_delegators :@item, :[], :dig, :fetch

      def initialize(item = {})
        @item = JSON.parse(item.to_json)
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
        Time.at(@item.dig("data", "created_utc").to_i).utc
      end

      def fullname
        "#{kind}_#{id}"
      end

      def id
        @item.dig("data", "id")
      end

      def kind
        @item.dig("kind")
      end

      def permalink
        @item.dig("data", "permalink")
      end

      def title
        @item.dig("data", "title")
      end

      def to_slack
        {
          blocks: [
            {
              type: "image",
              title: {
                type: "plain_text",
                text: "/r/brutalism",
                emoji: true,
              },
              image_url: url,
              alt_text: title,
            },
            {
              type: "context",
              elements: [
                {
                  type: "mrkdwn",
                  text: "<https://reddit.com#{permalink}|#{title}>",
                },
              ],
            },
          ],
        }
      end

      def url
        images = @item.dig("data", "preview", "images")
        source = images.map{|x| x["source"] }.compact.max do |a,b|
          a.slice("width", "height").values <=> b.slice("width", "height").values
        end
        CGI.unescapeHTML(source.dig("url"))
      rescue NoMethodError
        @item.dig("data", "media_metadata")&.values&.first&.dig("s", "u")
      end
    end
  end
end
