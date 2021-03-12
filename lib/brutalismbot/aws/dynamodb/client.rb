require "aws-sdk-dynamodb"

require "brutalismbot/aws/client"
require "brutalismbot/aws/dynamodb/item"
require "brutalismbot/aws/dynamodb/query"
require "brutalismbot/reddit/post"
require "brutalismbot/slack/post"
require "brutalismbot/slack/webhook"
require "brutalismbot/twitter/app"
require "brutalismbot/twitter/post"

module Brutalismbot
  module Aws
    module DynamoDB
      class Client < Aws::Client
        ENDPOINT = ENV["BRUTALISMBOT_DYNAMODB_ENDPOINT"]
        TABLE    = ENV["BRUTALISMBOT_DYNAMODB_TABLE"] || "Brutalismbot"

        ##
        # GET /reddit/posts/created_utc
        def list_reddit_posts_created_utc
          options = {
            index_name:                  "TYPE_CHRONO",
            key_condition_expression:    "#TYPE = :TYPE",
            projection_expression:       "#CREATED_UTC",
            expression_attribute_names:  { "#CREATED_UTC" => "CREATED_UTC", "#TYPE" => "TYPE" },
            expression_attribute_values: { ":TYPE" => "REDDIT/POST" },
          }
          query(**options, &:created_utc)
        end

        ##
        # GET /reddit/posts?name=
        def list_reddit_posts(prefix:nil, limit:nil)
          options = {
            index_name:                  "TYPE_KEY",
            limit:                       limit,
            key_condition_expression:    "#TYPE = :TYPE AND begins_with(#KEY, :KEY)",
            expression_attribute_names:  { "#KEY" => "KEY", "#TYPE" => "TYPE" },
            expression_attribute_values: { ":KEY" => "REDDIT/POST", ":TYPE" => "REDDIT/POST" },
          }.compact

          options[:expression_attribute_values][":KEY"] += "/#{ prefix }" if prefix

          query(**options) { |item| Reddit::Post.new(**item) }
        end

        ##
        # GET /slack/posts?name=
        def list_slack_posts(reddit_name:nil, team_id:nil, channel_id:nil, limit:nil)
          options = {
            index_name:                  "TYPES",
            limit:                       limit,
            key_condition_expression:    "#TYPE = :TYPE AND begins_with(#KEY, :KEY)",
            expression_attribute_names:  { "#KEY" => "KEY", "#TYPE" => "TYPE" },
            expression_attribute_values: { ":KEY" => "SLACK/POST", ":TYPE" => "SLACK/POST" },
          }.compact

          if reddit_name && team_id && channel_id
          elsif team_id
          elsif channel_id
          end

          options[:expression_attribute_values][":KEY"] += "/#{ name }" if name

          query(**options) { |item| Slack::Post.new(**item) }
        end

        ##
        # GET /slack/webhooks?team_id=&channel_id=
        def list_slack_webhooks(team_id:nil, channel_id:nil, limit:nil)
          to_webhook = -> (item) { Slack::Webhook.new(**item) }
          if team_id && channel_id
            query(**{
              index_name:                  "SLACK_WEBHOOKS",
              limit:                       limit,
              key_condition_expression:    "#T = :T AND #C = :C",
              expression_attribute_names:  { "#T" => "SLACK_TEAM_ID", "#C" => "SLACK_CHANNEL_ID" },
              expression_attribute_values: { ":T" => team_id, ":C" => channel_id },
            }.compact)
          elsif team_id
            query(**{
              index_name:                  "SLACK_WEBHOOKS",
              limit:                       limit,
              key_condition_expression:    "#T = :T",
              expression_attribute_names:  { "#T" => "SLACK_TEAM_ID" },
              expression_attribute_values: { ":T" => team_id },
            }.compact)
          else
            scan(index_name: "SLACK_WEBHOOKS", &to_webhook)
          end
        end

        ##
        # PUT /reddit/posts < *Brutalismbot::Reddit::Post
        def put_reddit_posts(*posts)
          items = Enumerator.new do |enum|
            type = "REDDIT/POST"
            posts.each do |post|
              key  =  "#{ type }/#{ post.name }"
              enum.yield({
                KEY:         key,
                TYPE:        type,
                CREATED_UTC: post.created_utc.to_i,
                DATA:        post.to_h,
                PERMALINK:   post.permalink,
                REDDIT_NAME: post.name,
                TITLE:       post.title,
              })
            end
          end

          put_items(*items)
        end

        ##
        # PUT /slack/webhooks/posts < *Brutalismbot::Slack::Post
        def put_slack_posts(*posts)
          items = Enumerator.new do |enum|
            hash = "SLACK/POST/#{ post.team_id }/#{ post.channel_id }/#{ post.created_utc.to_i }/#{ post.reddit_name }",
            posts.each do |post|
              enum.yield({
                HASH: hash,
                SORT: "REDDIT/POST/#{ post.created_utc.to_i }/#{ post.reddit_name }",
              })
              enum.yield({
                HASH: hash,
                SORT: "SLACK/WEBHOOK/#{ post.team_id }/#{ post.channel_id }",
              })
            end
          end

          put_items(*items)
        end

        ##
        # PUT /slack/webhooks < *Brutalismbot::Slack::Webhook
        def put_slack_webhooks(*webhooks)
          items = Enumerator.new do |enum|
            type = "SLACK/WEBHOOK"
            webhooks.each do |webhook|
              webhook_id = "#{ webhook.team_id }/#{ webhook.channel_id }"
              key        = "#{ type }/#{ webhook_id }"
              enum.yield({
                KEY:               key,
                TYPE:              type,
                DATA:              webhook.to_h,
                SLACK_CHANNEL:     webhook.channel_name,
                SLACK_CHANNEL_ID:  webhook.channel_id,
                SLACK_TEAM:        webhook.team_name,
                SLACK_TEAM_ID:     webhook.team_id,
                SLACK_WEBHOOK_ID:  webhook_id,
                SLACK_WEBHOOK_URL: webhook.url.to_s,
              })
            end
          end

          put_items(*items)
        end

        ##
        # PUT /twitter/apps < *Brutalismbot::Twitter:App
        def put_twitter_apps(*apps)
          items = Enumerator.new do |enum|
            type = "TWITTER/APP"
            apps.each do |app|
              app_id = app.handle
              key    = "#{ type }/#{ app_id }"
              enum.yield({
                KEY:             key,
                TYPE:            type,
                AWS_SECRET_NAME: app.secret_name,
                TWITTER_HANDLE:  app.handle,
                TWITTER_APP_ID:  app_id,
              })
            end
          end

          put_items(*items)
        end

        ##
        # PUT /twitter/apps/posts < *Brutalismbot::Twitter::Post
        def put_twitter_posts(*posts)
          items = Enumerator.new do |enum|
            posts.each do |post|
              post.tweets.each do |tweet|
                hash = "TWITTER/POST/#{ post.handle }/#{ tweet.id }/#{ post.created_utc.to_i }/#{ post.reddit_name }"
                enum.yield({
                  HASH: hash,
                  SORT: "REDDIT/POST/#{ post.created_utc.to_i }/#{ post.reddit_name }",
                })
                enum.yield({
                  HASH: hash,
                  SORT: "TWITTER/APP/#{ post.handle }",
                })
              end
            end
          end

          put_items(*items)
        end

        ##
        # DynamoDB table
        def table
          @table ||= ::Aws::DynamoDB::Table.new(name: TABLE, client: @client)
        end

        private

        ##
        # Default DynamoDB client
        def default_client
          ::Aws::DynamoDB::Client.new(**{ endpoint: ENDPOINT }.compact)
        end

        ##
        # DynamoDB endpoint URL
        def client_url
          File.join(table.client.config.endpoint.to_s, table.name)
        end

        ##
        # DynamoDB batch write
        def batch_write_item(*items, &block)
          total = items.count / 25 + 1
          items.each_slice(25).each_with_index do |page, i|
            Brutalismbot.logger.info("BATCH WRITE #{ client_url } [#{ i + 1 }/#{ total }]")
            @client.batch_write_item(request_items: { table.name => page.map(&block) })
          end
        end

        ##
        # DynamoDB PUT
        def put_items(*items)
          batch_write_item(*items) { |item| { :put_request => { item: item } } }
        end

        ##
        # DynamoDB QUERY
        def query(**options, &block)
          Query.new(table, **options, &block)
        end
      end
    end
  end
end
