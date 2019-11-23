RSpec.describe Brutalismbot::Slack::Client do
  let :auths do
    4.times.map{ Brutalismbot::Slack::Auth.stub }.sort{|a,b| a.team_id <=> b.team_id }
  end

  subject do
    Brutalismbot::Slack::Client.stub { auths }
  end

  context "#install" do
    let(:key)  { subject.key_for auths.first }
    let(:body) { auths.first.to_json }

    it "should add an auth object to storage" do
      expect(subject.bucket).to receive(:put_object).with(key: key, body: body)
      subject.install(auths.first)
    end
  end

  context "#key_for" do
    it "should return the key for a post" do
      expect(subject.key_for auths.first).to eq File.join(subject.prefix, auths.first.path)
    end
  end

  context "#list" do
    it "should return a prefix listing" do
      expect(subject.list.map(&:path)).to eq auths.map(&:path)
    end
  end

  context "#push" do
    let(:ok)   { Net::HTTPOK.new "1.1", "204", "ok" }
    let(:post) { Brutalismbot::Reddit::Post.stub }

    before do
      allow_any_instance_of(Brutalismbot::Slack::Auth).to receive(:push).and_return ok
    end

    it "should push a post to all auth'd Slack workspaces" do
      expect(subject.push(post)).to eq auths.map{ ok }
    end
  end

  context "#uninstall" do
    let(:key)  { subject.key_for auths.first }
    let(:body) { auths.first.to_json }

    it "should remove an auth from storage" do
      expect(subject.bucket).to receive(:delete_objects).with(delete: {objects: [{key: key}]})
      subject.uninstall(auths.first)
    end
  end
end
