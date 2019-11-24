RSpec.describe Brutalismbot::Twitter::Client do
  let(:post) { Brutalismbot::Reddit::Post.stub }

  let :file do
    file = Tempfile.new
    file.write("FIZZBUZZ")
    file
  end

  before do
    file.flush
  end

  after do
    file.close
    file.unlink
  end

  context "#push" do
    it "should push a post to Twitter" do
      expect_any_instance_of(URI::HTTPS).to receive(:open).and_yield(file)
      expect(subject.client).to receive(:update_with_media).with(post.to_twitter, file)
      subject.push(post)
    end
  end
end
