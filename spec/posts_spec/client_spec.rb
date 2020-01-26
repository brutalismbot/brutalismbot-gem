RSpec.describe Brutalismbot::Posts::Client do
  let :now do
    Time.now + 172800
  end

  let :posts do
    4.times.map{ Brutalismbot::Reddit::Post.stub }.sort{|a,b| a.created_utc <=> b.created_utc }
  end

  subject do
    Brutalismbot::Posts::Client.stub posts
  end

  before do
    allow(Time).to receive(:now).and_return now
  end

  context "#key_for" do
    let(:key) { File.join subject.prefix, posts.first.path }

    it "should return the key for a post" do
      expect(subject.key_for posts.first).to eq key
    end
  end

  context "#last" do
    it "should return the last post" do
      expect(subject.last.id).to eq posts.last.id
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

  context "#push" do
    let(:key)  { subject.key_for posts.first }
    let(:body) { posts.first.to_json }

    it "should push the post to storage" do
      expect(subject.bucket).to receive(:put_object).with(key: key, body: body)
      expect(subject.push(posts.first)).to eq(
        bucket: subject.bucket.name,
        key:    subject.key_for(posts.first),
      )
    end
  end
end
