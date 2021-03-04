require "aws-sdk-cloudwatch"

require "brutalismbot/aws/client"

module Brutalismbot
  module Aws
    module CloudWatch
      ENDPOINT = ENV["BRUTALISMBOT_CLOUDWATCH_ENDPOINT"]

      class Client < Aws::Client
        def put_queue_size(size)
          put_metric_data(
            namespace: "Brutalismbot/Reddit",
            metric_data: [
              { metric_name: "QueueSize", unit: "Count", value: size }
            ]
          )

          size
        end

        private

        def default_client
          ::Aws::CloudWatch::Client.new(**{ endpoint: ENDPOINT }.compact)
        end

        def put_metric_data(namespace:, **options)
          url = File.join(client.config.endpoint.to_s, namespace)
          Brutalismbot.logger.info("PUT METRIC #{ url } #{ options.to_json }")
          @client.put_metric_data(namespace: namespace, **options)
        end
      end
    end
  end
end
