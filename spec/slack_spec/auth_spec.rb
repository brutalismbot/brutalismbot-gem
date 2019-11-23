RSpec.describe Brutalismbot::Slack::Auth do
  subject do
    Brutalismbot::Slack::Auth.stub bot_id: "B", channel_id: "C", team_id: "T"
  end

  context "#channel_id" do
    it "should return the channel ID of the incoming webhook" do
      expect(subject.channel_id).to eq "C"
    end
  end

  context "#team_id" do
    it "should return the team ID" do
      expect(subject.team_id).to eq "T"
    end
  end

  context "#webhook_url" do
    it "should return the webhook URL" do
      expect(subject.webhook_url).to eq "https://hooks.slack.com/services/T/B/1234567890abcdef12345678"
    end
  end

  context "#path" do
    it "should return the S3 path for the auth" do
      expect(subject.path).to eq "team=T/channel=C/oauth.json"
    end
  end

  context "#push" do
    let(:ok)   { Net::HTTPOK.new "1.1", "204", "ok" }
    let(:post) { Brutalismbot::Reddit::Post.stub }

    it "should push a post to the workspace" do
      expect_any_instance_of(Net::HTTP).to receive(:request).and_return ok
      expect(subject.push(post)).to eq ok
    end

    it "should NOT push a post to the workspace" do
      expect_any_instance_of(Net::HTTP).not_to receive(:request)
      subject.push post, dryrun: true
    end
  end
end