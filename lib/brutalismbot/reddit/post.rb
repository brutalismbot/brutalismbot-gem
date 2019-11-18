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
        Time.at(data["created_utc"].to_i).utc
      end

      def fullname
        "#{kind}_#{id}"
      end

      def data
        @item.fetch("data", {})
      end

      def id
        data["id"]
      end

      def kind
        data["kind"]
      end

      def permalink
        "https://reddit.com#{data["permalink"]}"
      end

      def title
        data["title"]
      end

      def url
        images = data.dig("preview", "images") || {}
        source = images.map{|x| x["source"] }.compact.max do |a,b|
          a.slice("width", "height").values <=> b.slice("width", "height").values
        end
        CGI.unescapeHTML(source.dig("url"))
      rescue NoMethodError
        data["media_metadata"]&.values&.first&.dig("s", "u")
      end
    end
  end
end
