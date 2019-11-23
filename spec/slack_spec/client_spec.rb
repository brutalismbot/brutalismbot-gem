RSpec.describe Brutalismbot::Slack::Client do
  let :auths do
    4.times.map{ Brutalismbot::Slack::Auth.stub }.sort{|a,b| a.team_id <=> b.team_id }
  end

  subject do
    Brutalismbot::Slack::Client.stub { auths }
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
end
