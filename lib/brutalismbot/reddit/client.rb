require "brutalismbot/version"
require "brutalismbot/reddit/post_collection"

module Brutalismbot
  module Reddit
    class Client
      attr_reader :endpoint, :user_agent

      def initialize(endpoint:nil, user_agent:nil)
        @endpoint   = endpoint   || "https://www.reddit.com/r/brutalism"
        @user_agent = user_agent || "Brutalismbot #{Brutalismbot::VERSION}"
      end

      def posts(resource, params = {})
        url = File.join(@endpoint, "#{resource}.json")
        qry = URI.encode_www_form(params)
        uri = URI.parse("#{url}?#{qry}")
        PostCollection.new(uri: uri, user_agent: @user_agent)
      end
    end
  end
end
