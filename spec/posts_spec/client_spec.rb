RSpec.describe Brutalismbot::Posts::Client do
  let :posts do
    4.times.map{ Brutalismbot::Reddit::Post.stub }.sort{|a,b| a.created_utc <=> b.created_utc }
  end

  subject do
    Brutalismbot::Posts::Client.stub { posts }
  end

  context "#key_for" do
    it "should return the key for a post" do
      expect(subject.key_for posts.first).to eq File.join(subject.prefix, posts.first.path)
    end
  end

  context "#list" do
    it "should return a prefix listing" do
      expect(subject.list.map(&:id)).to eq posts.map(&:id)
    end
  end

  context "#max_key" do
    it "should return the max key" do
      expect(subject.max_key.key).to eq subject.key_for posts.last
    end
  end

  context "#max_time" do
    it "should return the max time" do
      expect(subject.max_time).to eq posts.last.created_utc.to_i
    end
  end
end
