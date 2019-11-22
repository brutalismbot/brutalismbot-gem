require "forwardable"
require "json"
require "net/http"

require "brutalismbot/logger"
require "brutalismbot/base"

module Brutalismbot
  module Slack
    class Auth < Base
      def channel_id
        @item.dig("incoming_webhook", "channel_id")
      end

      def team_id
        @item.dig("team_id")
      end

      def webhook_url
        @item.dig("incoming_webhook", "url")
      end

      def push(post, dryrun:nil)
        uri = URI.parse(webhook_url)
        Brutalismbot.logger.info("POST #{"DRYRUN " if dryrun}#{uri}")
        unless dryrun
          ssl = uri.scheme == "https"
          req = Net::HTTP::Post.new(uri, "content-type" => "application/json")
          req.body = post.to_slack.to_json
          Net::HTTP.start(uri.host, uri.port, use_ssl: ssl) do |http|
            http.request(req)
          end
        else
          Net::HTTPOK.new("1.1", "204", "ok")
        end
      end
    end
  end
end
