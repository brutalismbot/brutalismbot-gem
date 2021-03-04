require "aws-sdk-secretsmanager"

require "brutalismbot/aws/client"

module Brutalismbot
  module Aws
    module SecretsManager
      class Client < Aws::Client
        ENDPOINT = ENV["BRUTALISMBOT_SECRETSMANAGER_ENDPOINT"]

        def export(**options)
          secrets = JSON.parse(get_secret_value(**options).secret_string)

          ENV.update(secrets)

          nil
        end

        private

        def default_client
          ::Aws::SecretsManager::Client.new(**{ endpoint: ENDPOINT }.compact)
        end

        def get_secret_value(**options)
          Brutalismbot.logger.info("GET SECRET #{ options.to_json }")
          @client.get_secret_value(**options)
        end
      end
    end
  end
end
