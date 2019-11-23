require "aws-sdk-s3"

module Brutalismbot
  module S3
    class Client
      attr_reader :bucket, :prefix, :client

      def initialize(bucket:nil, prefix:nil, client:nil)
        bucket ||= ENV["S3_BUCKET"] || "brutalismbot"
        prefix ||= ENV["S3_PREFIX"] || "data/v1/"
        client ||= Aws::S3::Client.new
        @bucket = Aws::S3::Bucket.new(name: bucket, client: client)
        @client = client
        @prefix = prefix
      end

      def list(options = {}, &block)
        Brutalismbot.logger.info("LIST s3://#{@bucket.name}/#{@prefix}*")
        prefix = @bucket.objects({prefix: @prefix}.merge(options))
        Prefix.new(prefix, &block)
      end
    end
  end
end
