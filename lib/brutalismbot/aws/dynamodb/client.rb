require "aws-sdk-dynamodb"

require "brutalismbot/aws/client"
require "brutalismbot/aws/dynamodb/query"
require "brutalismbot/reddit/post"
require "brutalismbot/slack/post"
require "brutalismbot/slack/webhook"

module Brutalismbot
  module Aws
    module DynamoDB
      class Client < Aws::Client
        ENDPOINT = ENV["BRUTALISMBOT_DYNAMODB_ENDPOINT"]
        TABLE    = ENV["BRUTALISMBOT_DYNAMODB_TABLE"] || "Brutalismbot"

        def table
          @table ||= ::Aws::DynamoDB::Table.new(name: TABLE, client: @client)
        end

        def delete_reddit_posts(*posts)
          keys = posts.map do |post|
            hash = "REDDIT/POST/#{ post.created_utc.to_i }/#{ post.name }"
            list_hash_keys(hash).all
          end.flatten

          delete_items(*keys)
        end

        def delete_slack_webhooks(*webhooks)
        end

        def get_reddit_post(key)
          get_item(HASH: key, SORT: "REDDIT/POST") { |item| Reddit::Post.new(**item) }
        end

        def get_slack_post(key)
          get_item(HASH: key, SORT: "SLACK/POST") { |item| Slack::Post.new(**item) }
        end

        def get_slack_webhook(key)
          get_item(HASH: key, SORT: "SLACK/WEBHOOK") { |item| Slack::Webhook.new(**item) }
        end

        def list_reddit_posts(**options)
          list_sort_key_items("REDDIT/POST", **options) { |item| Reddit::Post.new(**item) }
        end

        def list_slack_posts(**options)
          list_sort_key_items("SLACK/POST", **options) { |item| Slack::Post.new(**item) }
        end

        def list_slack_webhooks(**options)
          list_sort_key_items("SLACK/WEBHOOK", **options) { |item| Slack::Webhook.new(**item) }
        end

        def list_twitter_posts(**options)
          list_sort_key_items("TWITTER/POST", **options) { |item| Twitter::Post.new(**item) }
        end

        def put_reddit_posts(*posts)
          items = Enumerator.new do |enum|
            posts.map do |post|
              hash = File.join("REDDIT/POST", post.created_utc.to_i.to_s, post.name)
              base = {
                HASH:        hash,
                CREATED_UTC: post.created_utc.to_i,
                NAME:        post.name,
                PERMALINK:   post.permalink,
              }
              enum.yield({ **base, SORT: "REDDIT/POST",  DATA: post.to_h })
              enum.yield({ **base, SORT: "SLACK/POST",   DATA: post.to_slack })
              enum.yield({ **base, SORT: "TWITTER/POST", DATA: post.to_twitter })
            end
          end

          put_items(*items) { |items| items.map { |item| item[:HASH] }.uniq }
        end

        def put_slack_webhooks(*webhooks)
          items = webhooks.map do |webhook|
            sort = "SLACK/WEBHOOK"
            hash = File.join(sort, webhook.team_id, webhook.channel_id)
            {
              HASH:    hash,
              SORT:    sort,
              TEAM:    webhook.team_name,
              CHANNEL: webhook.channel_name,
              WEBHOOK: webhook.url,
              DATA:    webhook.to_h,
            }
          end

          put_items(*items)
        end

        private

        def default_client
          ::Aws::DynamoDB::Client.new(**{ endpoint: ENDPOINT }.compact)
        end

        def batch_write_item(*items, &block)
          total = items.count / 25 + 1
          items.each_slice(25).each_with_index do |page, i|
            Brutalismbot.logger.info("BATCH WRITE [#{ i + 1 }/#{ total }]")
            @client.batch_write_item(request_items: { table.name => page.map(&block) })
          end
        end

        def delete_items(*keys, &block)
          batch_write_item(*keys) { |key| { :delete_request => { key: key } } }
          block_given? ? yield(keys) : keys
        end

        def get_item(**key, &block)
          url = File.join(table.client.config.endpoint.to_s, table.name)
          Brutalismbot.logger.info("GET ITEM #{ url } #{ key.to_json }")
          item = table.get_item(key: key).item
          yield item["DATA"] unless item.nil?
        end

        def list_hash_keys(hash_key, **options, &block)
          options.update(
            key_condition_expression:    "#HASH = :HASH",
            projection_expression:       "#HASH, #SORT",
            expression_attribute_names:  { "#HASH" => "HASH", "#SORT" => "SORT" },
            expression_attribute_values: { ":HASH" => hash_key },
          )
          query(**options)
        end

        def list_sort_key_items(sort_key, **options, &block)
          options.update(
            index_name:                  "SORT",
            key_condition_expression:    "#SORT = :SORT",
            projection_expression:       "#DATA",
            expression_attribute_names:  { "#DATA" => "DATA", "#SORT" => "SORT" },
            expression_attribute_values: { ":SORT" => sort_key },
          )
          query(**options) { |item| yield item["DATA"] }
        end

        def put_item(**item, &block)
          url = File.join(table.client.config.endpoint.to_s, table.name)
          Brutalismbot.logger.info("PUT ITEM #{ url }")
          table.put_item(item: item)
          block_given? ? yield(item) : item
        end

        def put_items(*items, &block)
          batch_write_item(*items) { |item| { :put_request => { item: item } } }
          block_given? ? yield(items) : items
        end

        def query(**options, &block)
          Query.new(table, **options, &block)
        end
      end
    end
  end
end
