require "aws-sdk-s3"

require "brutalismbot/version"
require "brutalismbot/reddit/resource"

module Brutalismbot
  module Reddit
    module Environment
      def env
        new(
          endpoint:   ENV["REDDIT_ENDPOINT"],
          user_agent: ENV["REDDIT_USER_AGENT"],
        )
      end
    end

    class Client
      extend Environment

      attr_reader :endpoint, :user_agent

      def initialize(endpoint:nil, user_agent:nil)
        @endpoint   = endpoint   || "https://www.reddit.com/r/brutalism"
        @user_agent = user_agent || "Brutalismbot #{Brutalismbot::VERSION}"
      end

      def list(resource, options = {})
        url = File.join(@endpoint, "#{resource}.json")
        qry = URI.encode_www_form(options)
        uri = URI.parse("#{url}?#{qry}")
        Resource.new(uri: uri, user_agent: @user_agent)
      end
    end
  end
end
