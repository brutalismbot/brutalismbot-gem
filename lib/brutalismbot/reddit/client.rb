require "aws-sdk-s3"

require "brutalismbot/version"
require "brutalismbot/reddit/resource"

module Brutalismbot
  module Reddit
    class Client
      attr_reader :endpoint, :user_agent

      def initialize(endpoint:nil, user_agent:nil)
        @endpoint   = endpoint   || ENV["REDDIT_ENDPOINT"]   || "https://www.reddit.com/r/brutalism"
        @user_agent = user_agent || ENV["REDDIT_USER_AGENT"] || "Brutalismbot v#{Brutalismbot::VERSION}"
      end

      def list(resource, options = {})
        url = File.join(@endpoint, "#{resource}.json")
        qry = URI.encode_www_form(options)
        uri = "#{url}?#{qry}"
        Resource.new(uri: uri, user_agent: @user_agent)
      end
    end
  end
end
