require "brutalismbot/logging"
require "brutalismbot/base/enumerable"
require "brutalismbot/reddit/post"

module Brutalismbot
  module Reddit
    class Listing
      include Base::Enumerable

      def initialize(endpoint, **headers)
        @endpoint = endpoint
        @headers  = headers
        @filters  = []
      end

      def inspect
        "#<#{ self.class } #{ @endpoint }>"
      end

      def each
        Brutalismbot.logger.info("GET #{ @endpoint }")
        URI.open(@endpoint, **@headers) do |stream|
          # Parse Reddit response
          data  = JSON.parse(stream.read).dig("data", "children")
          # Convert to Reddit::Post items
          posts = data.map { |child| Post.new(**child) }
          # Apply @selects
          block = -> (items, block) { items.then(&block) }
          @filters.reduce(posts, &block).each { |post| yield post }
        end
      end

      def after(time)
        selector = -> (post) { post.created_utc > time }
        tap { @filters << -> (posts) { posts.select(&selector) } }
      end

      def before(time)
        selector = -> (post) { post.created_utc <= time }
        tap { @filters << -> (posts) { posts.select(&selector) } }
      end
    end
  end
end
