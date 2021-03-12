require "brutalismbot/logging"
require "brutalismbot/base/enumerable"
require "brutalismbot/reddit/post"

module Brutalismbot
  module Reddit
    module Listable
      include Base::Enumerable

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
          # Yield posts
          posts.each { |post| yield post }
        end
      end
    end
  end
end
