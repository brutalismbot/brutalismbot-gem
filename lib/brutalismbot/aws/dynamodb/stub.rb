require "securerandom"

require "brutalismbot/aws/dynamodb/table"
require "brutalismbot/slack/stub"
require "brutalismbot/reddit/stub"

module Brutalismbot
  module Aws
    module DynamoDB
      module Stubbable
        def stub(stubs = nil)
          stubs ||= 4.times.map { Slack::Auth.stub } + 16.times.map { Reddit::Post.stub }

          items = stubs.map(&:to_dynamodb).map { |x| x.transform_keys(&:to_s) }

          client = Aws::DynamoDB::Client.new(stub_responses: true)

          client.stub_responses :query, -> (context) do
            case context.params.slice(:index_name, :key_condition_expression).values
            when [ "TYPE", "#TYPE = :TYPE" ]
              type   = context.params[:expression_attribute_values][":TYPE"][:s]
              filter = -> (x) { x["TYPE"] == type }
              { items: items.select(&filter)  }
            end
          end

          new(client: client)
        end
      end

      Table.extend(Stubbable)
    end
  end
end
