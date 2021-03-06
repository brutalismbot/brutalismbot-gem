require "json"
require "securerandom"

require "aws-sdk-s3"

require "brutalismbot/slack/auth"

module Brutalismbot
  module Slack
    class Client
      def stub!(items = nil)
        items ||= [Auth.stub]
        items   = items.map{|x| [key_for(x), x.to_h] }.to_h

        @client = Aws::S3::Client.new(stub_responses: true)

        @client.stub_responses :list_objects_v2, -> (context) do
          keys = items.keys.select{|x| x.start_with? context.params[:prefix] }
          {contents: keys.map{|x| {key:x} }}
        end

        @client.stub_responses :get_object, -> (context) do
          {body: StringIO.new(items.fetch(context.params[:key]).to_json)}
        end

        @client.stub_responses :delete_object, -> (context) do
          {version_id: context.params[:key]}
        end

        @stubbed = true

        self
      end

      class << self
        def stub(items = nil)
          new(prefix: "data/test/auths/").stub!(items)
        end
      end
    end

    class Auth
      class << self
        def stub(bot_id:nil, channel_id:nil, team_id:nil, user_id:nil)
          bot_id     ||= "B#{SecureRandom.alphanumeric(8).upcase}"
          channel_id ||= "C#{SecureRandom.alphanumeric(8).upcase}"
          team_id    ||= "T#{SecureRandom.alphanumeric(8).upcase}"
          user_id    ||= "U#{SecureRandom.alphanumeric(8).upcase}"
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
end
