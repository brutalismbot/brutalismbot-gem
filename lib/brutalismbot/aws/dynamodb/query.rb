require "json"

require "brutalismbot/logging"
require "brutalismbot/base/enumerable"
require "brutalismbot/aws/dynamodb/item"

module Brutalismbot
  module Aws
    module DynamoDB
      class Query
        include Base::Enumerable

        attr_reader :table, :options, :block

        def initialize(table, **options, &block)
          @table   = table
          @options = options
          @block   = block || -> (object) { object }
        end

        def each
          limit = @options.fetch(:limit, -1)
          pager = -> (**options) do
            res = execute(**options)
            res.items[0..limit].each { |item| yield Item.new(item).then(&@block) }
            limit -= res.count
            res
          end

          res = pager.call
          until res.last_evaluated_key.nil? || limit <= 0
            res = pager.call(exclusive_start_key: res.last_evaluated_key)
          end
        end

        def first
          one(scan_index_forward: true)
        end

        def last
          one(scan_index_forward: false)
        end

        private

        def client_url
          File.join(@table.client.config.endpoint.to_s, @table.name)
        end

        def one(scan_index_forward:)
          res = execute(limit: 1, scan_index_forward: scan_index_forward)
          res.items.map { |item| Item.new(item).then(&@block) }.first
        end

        def execute(**options)
          options = { **@options, **options }
          Brutalismbot.logger.info("QUERY #{ client_url } #{ options.to_json }")
          @table.query(**options)
        end
      end
    end
  end
end
