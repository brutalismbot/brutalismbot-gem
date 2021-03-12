require "brutalismbot/aws/cloudwatch"
require "brutalismbot/aws/dynamodb"
require "brutalismbot/reddit/client"
require "brutalismbot/slack/client"
require "brutalismbot/twitter/client"

module Brutalismbot
  class Client
    def inspect
      "#<#{self.class}>"
    end

    def metrics
      @metrics ||= Brutalismbot::Aws::CloudWatch::Client.new
    end

    def storage
      @storage ||= Brutalismbot::Aws::DynamoDB::Client.new
    end

    def reddit
      @reddit ||= Reddit::Client.new(storage)
    end

    def slack
      @slack ||= Slack::Client.new(storage)
    end

    def twitter
      @twitter ||= Twitter::Client.new(storage)
    end
  end
end
