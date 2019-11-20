require "aws-sdk-s3"

module Brutalismbot
  module S3
    class Client
      attr_reader :prefix, :client

      def initialize(bucket:nil, prefix:nil, client:nil)
        @bucket = bucket || ENV["S3_BUCKET"] || "brutalismbot"
        @prefix = prefix || ENV["S3_PREFIX"] || "data/v1/"
        @client = client || Aws::S3::Client.new
      end

      def bucket(options = {})
        Aws::S3::Bucket.new({name: @bucket, client: @client}.merge(options))
      end
    end
  end
end
