require "brutalismbot/base/storage_collection"
require "brutalismbot/slack/webhook"

module Brutalismbot
  module Slack
    class WebhookCollection < Base::StorageCollection
      def get(team_id:, channel_id:)
        list(team_id:team_id, channel_id:channel_id, limit:1).first
      end

      def keys(limit:nil)
        @storage.list_slack_webhooks_keys(limit:limit)
      end

      def list(team_id:nil, channel_id:nil, limit:nil)
        @storage.list_slack_webhooks(team_id:team_id, channel_id:channel_id, limit:limit)
      end

      def new(webhook)
        Webhook.new(webhook)
      end

      def put(*webhooks)
        @storage.put_slack_webhooks(*webhooks) do |webhook|
          { team_id: webhook.team_id, channel_id: webhook.channel_id }
        end
      end
    end
  end
end
