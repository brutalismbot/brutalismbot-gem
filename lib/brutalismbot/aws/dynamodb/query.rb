require "json"

require "brutalismbot/base/enumerable"
require "brutalismbot/logger"

module Brutalismbot
  module Aws
    module DynamoDB
      class Query
        include Base::Enumerable

        attr_reader :table, :options, :block

        def initialize(table, **options, &block)
          @table   = table
          @options = options
          @block   = block || -> (item) { item }
        end

        def each
          limit = @options.fetch(:limit, -1)

          result = execute(**@options)
          result.items[0..limit].each { |item| yield item.then(&@block) }
          limit -= result.count

          until result.last_evaluated_key.nil? || limit <= 0
            result = execute(**@options, exclusive_start_key: result.last_evaluated_key)
            result.items[0..limit].each { |item| yield item.then(&@block) }
            limit -= result.count
          end
        end

        def first
          one(scan_index_forward: true)
        end

        def last
          one(scan_index_forward: false)
        end

        private

        def one(scan_index_forward:)
          extra = { limit: 1, scan_index_forward: scan_index_forward }
          execute(**@options, **extra).items.first&.then(&@block)
        end

        def execute(**options)
          url = File.join(@table.client.config.endpoint.to_s, @table.name)
          Brutalismbot.logger.info("QUERY #{ url } #{ options.to_json }")
          @table.query(**options)
        end
      end
    end
  end
end
