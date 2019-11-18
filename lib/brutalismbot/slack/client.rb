require "aws-sdk-s3"

require "brutalismbot/logger"
require "brutalismbot/slack/auth"

module Brutalismbot
  module Slack
    module Environment
      def env
        new(
          bucket: ENV["SLACK_S3_BUCKET"],
          prefix: ENV["SLACK_S3_PREFIX"],
        )
      end
    end

    class Client
      extend Environment
      include Enumerable

      attr_reader :prefix, :client

      def initialize(bucket:nil, prefix:nil, client:nil)
        @bucket = bucket || "brutalismbot"
        @prefix = prefix || "data/v1/auths/"
        @client = client || Aws::S3::Client.new
      end

      def bucket(options = {})
        Aws::S3::Bucket.new({name: @bucket, client: @client}.merge(options))
      end

      def each
        Brutalismbot.logger.info "LIST s3://#{@bucket}/#{@prefix}*"
        bucket.objects(prefix: @prefix).each do |object|
          yield Auth.parse(object.get.body.read)
        end
      end

      def key_for(auth)
        File.join(
          @prefix,
          "team=#{auth.team_id}",
          "channel=#{auth.channel_id}",
          "oauth.json",
        )
      end

      def install(auth, dryrun:nil)
        key = key_for(auth)
        Brutalismbot.logger.info "PUT #{"DRYRUN " if dryrun}s3://#{@bucket}/#{key}"
        bucket.put_object(key: key, body: auth.to_json) unless dryrun
      end

      def uninstall(auth, dryrun:nil)
        key = key_for(auth)
        Brutalismbot.logger.info "DELETE #{"DRYRUN " if dryrun}s3://#{@bucket}/#{key}"
        bucket.delete_objects(delete: {objects: [{key: key}]}) unless dryrun
      end

      def push(post, dryrun:nil)
        each do |auth|
          key = key_for(auth)
          Brutalismbot.logger.info "PUSH #{"DRYRUN " if dryrun}s3://#{@bucket}/#{key}"
          auth.post(post, dryrun: dryrun)
        end
      end
    end
  end
end
