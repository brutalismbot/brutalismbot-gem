RSpec.describe Brutalismbot::Twitter::Client do
  let(:post) { Brutalismbot::Reddit::Post.stub }

  let :media do
    Tempfile.new {|file| file.write("FIZZBUZZ") }
  end

  before do
    media.flush
  end

  after do
    media.close
    media.unlink
  end

  context "#push" do
    it "should push an image post to Twitter" do
      allow(post).to receive(:mime_type).and_return "image/jpeg"
      status, media_url = post.to_twitter.slice(:status, :media_url).values
      expect(URI).to receive(:open).with(media_url).and_yield(media)
      expect(subject.client).to receive(:update_with_media).with(status, media)
      subject.push(status: status, media_url: media_url)
    end

    it "should push a text post to Twitter" do
      allow(post).to receive(:mime_type).and_return "text/html; charset=utf-8"
      allow(post).to receive(:is_self?).and_return true
      status = post.to_twitter.slice :status
      expect(subject.client).to receive(:update).with(status)
      subject.push(status: status)
    end
  end
end
