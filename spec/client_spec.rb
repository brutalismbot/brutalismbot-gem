RSpec.describe Brutalismbot::Client do
  subject { Brutalismbot::Client.stub }

  context "#lag_time" do
    it "should return the default lag time" do
      expect(subject.lag_time).to eq 7200
    end
  end

  context "#pull" do
    let(:posts) { [Brutalismbot::Reddit::Post.stub] }

    it "should pull the latest posts" do
      expect(subject.reddit).to receive(:list).and_return(posts)
      expect(subject.posts).to  receive(:push).with(posts.first, dryrun: nil)
      subject.pull
    end
  end

  context "#push" do
    let(:post) { Brutalismbot::Reddit::Post.stub }

    it "should push a post to Twitter and Slack" do
      expect(subject.slack).to   receive(:push).with(post, dryrun: nil)
      expect(subject.twitter).to receive(:push).with(post, dryrun: nil)
      subject.push(post)
    end
  end
end
