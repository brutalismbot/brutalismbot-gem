RSpec.describe Brutalismbot::Slack::Auth do
  let :s3 do
    {
      bucket: "brutalismbot",
      key: "data/test/auths/#{subject.path}",
      body: subject.to_json,
    }
  end

  subject do
    Brutalismbot::Slack::Auth.stub bot_id: "B", channel_id: "C", team_id: "T"
  end

  context "#channel_id" do
    it "should return the channel ID of the incoming webhook" do
      expect(subject.channel_id).to eq "C"
    end
  end

  context "#inspect" do
    it "should show the permalink on inspection" do
      expect(subject.inspect).to eq "#<Brutalismbot::Slack::Auth T/C>"
    end
  end

  context "#path" do
    it "should return the S3 path for the auth" do
      expect(subject.path).to eq "team=T/channel=C/oauth.json"
    end
  end

  context "#team_id" do
    it "should return the team ID" do
      expect(subject.team_id).to eq "T"
    end
  end

  context "#to_s3" do
    it "should return the S3 put_object input" do
      expect(subject.to_s3 bucket: "brutalismbot", prefix: "data/test/auths/").to eq s3
    end
  end

  context "#webhook_url" do
    it "should return the webhook URL" do
      expect(subject.webhook_url).to eq "https://hooks.slack.com/services/T/B/1234567890abcdef12345678"
    end
  end
end
