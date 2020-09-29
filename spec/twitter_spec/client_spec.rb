RSpec.describe Brutalismbot::Twitter::Client do
  let(:media)  { Tempfile.new {|file| file.write("FIZZBUZZ") } }
  let(:post)   { Brutalismbot::Reddit::Post.stub }
  let(:status) { "#{post.title}\n#{post.permalink}"}

  before do
    media.flush
  end

  after do
    media.close
    media.unlink
  end

  context "#push" do
    it "should push an image post to Twitter" do
      media_url = post.media_urls.first
      expect(URI).to receive(:open).with(media_url).and_return(media)
      expect(subject.client).to receive(:update_with_media).with(status, [media]).and_return(OpenStruct.new(id: 1))
      subject.push post
    end
  end
end
