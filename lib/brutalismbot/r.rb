module Brutalismbot
  module R
    class Subreddit
      attr_reader :endpoint, :user_agent

      def initialize(endpoint:nil, user_agent:nil)
        @endpoint   = endpoint
        @user_agent = user_agent
      end

      def posts(resource, **params)
        url = File.join @endpoint, "#{resource}.json"
        qry = URI.encode_www_form params
        uri = URI.parse "#{url}?#{qry}"
        PostCollection.new uri: uri, user_agent: @user_agent
      end
    end

    class PostCollection
      include Enumerable

      def initialize(uri:, user_agent:, min_time:nil)
        @uri        = uri
        @ssl        = uri.scheme == "https"
        @user_agent = user_agent
        @min_time   = min_time.to_i
      end

      def each
        Brutalismbot.logger.info "GET #{@uri}"
        Net::HTTP.start(@uri.host, @uri.port, use_ssl: @ssl) do |http|
          request  = Net::HTTP::Get.new @uri, "user-agent" => @user_agent
          response = JSON.parse http.request(request).body
          children = response.dig("data", "children") || []
          children.reverse.each do |child|
            post = Post[child]
            yield post if post.created_after time: @min_time
          end
        end
      end

      def since(time:)
        PostCollection.new uri: @uri, user_agent: @user_agent, min_time: time
      end
    end

    class Brutalism < Subreddit
      def initialize(endpoint:nil, user_agent:nil)
        super endpoint:   endpoint   || "https://www.reddit.com/r/brutalism",
              user_agent: user_agent || "Brutalismbot #{VERSION}"
      end
    end
  end
end
