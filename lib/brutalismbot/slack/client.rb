require "json"

require "brutalismbot/slack/post_collection"
require "brutalismbot/slack/webhook_collection"

module Brutalismbot
  module Slack
    class Client
      def initialize(storage)
        @storage = storage
      end

      def inspect
        "#<#{ self.class }>"
      end

      def posts
        PostCollection.new(@storage)
      end

      def webhooks
        WebhookCollection.new(@storage)
      end

      def push(post, webhook)
        url = webhook.url
        ssl = url.scheme == "https"
        res = Net::HTTP.start(url.host, url.port, use_ssl: ssl) do |http|
          Brutalismbot.logger.info("POST #{ url }")
          req = Net::HTTP::Post.new(url, "content-type" => "application/json")
          req.body = post.to_json
          http.request(req)
        end

        Brutalismbot.logger.error("RESPONSE [#{ res.code }] #{ res.message }")
        Slack::Response.new(res)
      end
    end
  end
end
