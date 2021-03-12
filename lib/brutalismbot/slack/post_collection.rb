require "brutalismbot/base/storage_collection"
require "brutalismbot/slack/post"

module Brutalismbot
  module Slack
    class PostCollection < Base::StorageCollection
      def get(name:)
        list(name:name, limit:1).first
      end

      def list(name:nil, team_id:nil, channel_id:nil, limit:nil)
        @storage.list_slack_posts(name:name, team_id:team_id, channel_id:channel_id, limit:limit)
      end
    end
  end
end
