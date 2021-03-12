require "aws-sdk-s3"

require "brutalismbot/aws/client"
require "brutalismbot/aws/s3/prefix"
require "brutalismbot/reddit/post"
require "brutalismbot/slack/webhook"

module Brutalismbot
  module Aws
    module S3
      class Client < Aws::Client
        ENDPOINT = ENV["BRUTALISMBOT_S3_ENDPOINT"]
        BUCKET   = ENV["BRUTALISMBOT_S3_BUCKET"] || "brutalismbot"
        PREFIX   = ENV["BRUTALISMBOT_S3_PREFIX"] || "data/v1/"

        def bucket
          @bucket ||= ::Aws::S3::Bucket.new(name: BUCKET, client: @client)
        end

        def list_reddit_posts(**options)
          prefix(prefix: File.join(PREFIX, "posts/")) { |obj| Reddit::Post.new(**obj) }
        end

        def list_slack_webhooks(**options)
          prefix(prefix: File.join(PREFIX, "auths/")) { |obj| Slack::Webhook.new(**obj) }
        end

        private

        def default_client
          ::Aws::S3::Client.new(**{ endpoint: ENDPOINT }.compact)
        end

        def prefix(**options, &block)
          Prefix.new(bucket, **options, &block)
        end
      end
    end
  end
end
