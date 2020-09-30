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
      expect(subject.client).to receive(:update_with_media).with(status, [media], {}).and_return(OpenStruct.new(id: 1))
      subject.push post
    end

    it "should slice 6 images into two tweets of 3" do
      allow(post).to receive(:media_urls).and_return [
        "<media-url-1>",
        "<media-url-2>",
        "<media-url-3>",
        "<media-url-4>",
        "<media-url-5>",
        "<media-url-6>",
      ]
      expect(URI).to receive(:open).with("<media-url-1>").and_return(media)
      expect(URI).to receive(:open).with("<media-url-2>").and_return(media)
      expect(URI).to receive(:open).with("<media-url-3>").and_return(media)
      expect(URI).to receive(:open).with("<media-url-4>").and_return(media)
      expect(URI).to receive(:open).with("<media-url-5>").and_return(media)
      expect(URI).to receive(:open).with("<media-url-6>").and_return(media)
      expect(subject.client).to receive(:update_with_media)
        .with(status, [media, media, media], {})
        .and_return(OpenStruct.new(id: 1))
      expect(subject.client).to receive(:update_with_media)
        .with(nil, [media, media, media], {in_reply_to_status_id: 1})
        .and_return(OpenStruct.new(id: 2))
      subject.push post
    end

    it "should slice 7 images into two tweets of 4 & 3" do
      allow(post).to receive(:media_urls).and_return [
        "<media-url-1>",
        "<media-url-2>",
        "<media-url-3>",
        "<media-url-4>",
        "<media-url-5>",
        "<media-url-6>",
        "<media-url-7>",
      ]
      expect(URI).to receive(:open).with("<media-url-1>").and_return(media)
      expect(URI).to receive(:open).with("<media-url-2>").and_return(media)
      expect(URI).to receive(:open).with("<media-url-3>").and_return(media)
      expect(URI).to receive(:open).with("<media-url-4>").and_return(media)
      expect(URI).to receive(:open).with("<media-url-5>").and_return(media)
      expect(URI).to receive(:open).with("<media-url-6>").and_return(media)
      expect(URI).to receive(:open).with("<media-url-7>").and_return(media)
      expect(subject.client).to receive(:update_with_media)
        .with(status, [media, media, media, media], {})
        .and_return(OpenStruct.new(id: 1))
      expect(subject.client).to receive(:update_with_media)
        .with(nil, [media, media, media], {in_reply_to_status_id: 1})
        .and_return(OpenStruct.new(id: 2))
      subject.push post
    end

    it "should retry on image size errors" do
      allow(post).to receive(:is_gallery?).and_return true
      expect(URI).to receive(:open).and_return(media)
      expect(URI).to receive(:open).and_return(media)
      expect(subject.client).to receive(:update_with_media)
        .and_raise(Twitter::Error::BadRequest.new("Image file size must be <= 9999 bytes"))
      expect(subject).to receive(:push_preview)
        .with(post, {}, 0)
        .and_return(OpenStruct.new(id: 1))
      subject.push post
    end
  end

  context "#push_preview" do
    it "should push the preview images" do
      allow(post).to receive(:is_gallery?).and_return true
      expect(URI).to receive(:open).and_return(media)
      expect(URI).to receive(:open).and_return(media)
      expect(subject.client).to receive(:update_with_media)
        .with(status, [media, media], {in_reply_to_status_id: 1})
        .and_return(OpenStruct.new(id: 1))
      subject.send(:push_preview, post, {in_reply_to_status_id: 1}, 0)
    end
  end
end
