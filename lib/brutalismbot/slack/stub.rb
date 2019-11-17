require "securerandom"

module Brutalismbot
  module Slack
    module Stub
      def stub
        bot_id     = "B#{SecureRandom.alphanumeric(8).upcase}"
        channel_id = "C#{SecureRandom.alphanumeric(8).upcase}"
        team_id    = "T#{SecureRandom.alphanumeric(8).upcase}"
        user_id    = "U#{SecureRandom.alphanumeric(8).upcase}"
        new(
          ok:           true,
          access_token: "<token>",
          scope:        "identify,incoming-webhook",
          user_id:      user_id,
          team_name:    "My Team",
          team_id:      team_id,
          incoming_webhook: {
            channel:           "#brutalism",
            channel_id:        channel_id,
            configuration_url: "https://my-team.slack.com/services/#{bot_id}",
            url:               "https://hooks.slack.com/services/#{team_id}/#{bot_id}/1234567890abcdef12345678",
          },
          scopes: [
            "identify",
            "incoming-webhook",
          ],
        )
      end
    end
  end
end
