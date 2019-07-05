module Brutalismbot
  module R
    class Subreddit
      attr_reader :endpoint, :user_agent

      def initialize(endpoint:nil, user_agent:nil)
        @endpoint   = endpoint
        @user_agent = user_agent || "Brutalismbot #{VERSION}"
      end

      def posts(resource, params = {})
        url = File.join @endpoint, "#{resource}.json"
        qry = URI.encode_www_form params
        uri = URI.parse "#{url}?#{qry}"
        PostCollection.new uri: uri, user_agent: @user_agent
      end
    end

    class PostCollection
      include Enumerable

      def initialize(uri:, user_agent:)
        @uri        = uri
        @ssl        = uri.scheme == "https"
        @user_agent = user_agent
      end

      def each
        Brutalismbot.logger.info "GET #{@uri}"
        Net::HTTP.start(@uri.host, @uri.port, use_ssl: @ssl) do |http|
          request  = Net::HTTP::Get.new @uri, "user-agent" => @user_agent
          response = JSON.parse http.request(request).body
          children = response.dig("data", "children") || []
          children.each do |child|
            post = Post[child]
            yield post
          end
        end
      end

      def all
        to_a
      end

      def last
        to_a.last
      end
    end

    class Brutalism < Subreddit
      def initialize(endpoint:nil, user_agent:nil)
        endpoint ||= "https://www.reddit.com/r/brutalism"
        super
      end
    end
  end
end
