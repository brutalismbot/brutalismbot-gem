require "forwardable"
require "json"
require "net/http"

require "brutalismbot/logger"
require "brutalismbot/parsable"
require "brutalismbot/slack/stub"

module Brutalismbot
  module Slack
    class Auth
      extend Parsable
      extend Forwardable
      extend Stub

      def_delegators :@item, :[], :dig, :fetch, :to_h, :to_json

      def initialize(item = {})
        @item = JSON.parse(item.to_json)
      end

      def channel_id
        @item.dig("incoming_webhook", "channel_id")
      end

      def team_id
        @item.dig("team_id")
      end

      def webhook_url
        @item.dig("incoming_webhook", "url")
      end

      def post(post, dryrun:nil)
        uri = URI.parse(webhook_url)
        Brutalismbot.logger.info("POST #{"DRYRUN " if dryrun}#{uri}")
        if dryrun
          Net::HTTPOK.new("1.1", "204", "ok")
        else
          ssl = uri.scheme == "https"
          req = Net::HTTP::Post.new(uri, "content-type" => "application/json")
          req.body = post.to_slack.to_json
          Net::HTTP.start(uri.host, uri.port, use_ssl: ssl) do |http|
            http.request(req)
          end
        end
      end
    end
  end
end
