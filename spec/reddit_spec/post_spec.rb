RSpec.describe Brutalismbot::Reddit::Post do
  let(:time_0) { Time.at 1234567000 }
  let(:time_1) { Time.at 1234567890 }
  let(:time_2) { Time.at 1234567900 }

  let :s3 do
    {
      bucket: "brutalismbot",
      key: "data/test/posts/#{subject.path}",
      body: subject.to_json,
    }
  end

  let :slack_image do
    {
      blocks: [
        {
          alt_text:  "Post to /r/brutalism",
          image_url: "https://image.host/abcdef.jpg",
          type:      "image",
          title: {
            emoji: true,
            text:  "/r/brutalism",
            type:  "plain_text",
          },
        },
        {
          type: "context",
          elements: [
            {
              text: "<https://reddit.com/r/brutalism/comments/abcdef/test/|Post to /r/brutalism>",
              type: "mrkdwn",
            },
          ],
        },
      ],
    }
  end

  let :slack_text do
    {
      blocks: [
        {
          type: "section",
          accessory: {
            alt_text: "/r/brutalism",
            image_url: "https://brutalismbot.com/logo-red-ppl.png",
            type: "image",
          },
          text: {
            text: "<https://reddit.com/r/brutalism/comments/abcdef/test/|Post to /r/brutalism>",
            type: "mrkdwn",
          },
        },
      ],
    }
  end

  let :twitter do
    {
      media_url: "https://image.host/abcdef.jpg",
      status: <<~EOS.strip
        Post to /r/brutalism
        https://reddit.com/r/brutalism/comments/abcdef/test/
      EOS
    }
  end

  subject do
    Brutalismbot::Reddit::Post.stub created_utc:  time_1,
                                    image_id:     "abcdef",
                                    permalink_id: "abcdef",
                                    post_id:      "abcdef"
  end

  context "#created_after?" do
    it "should indicate that it was created after the epoch" do
      expect(subject.created_after?(time_0)).to be true
    end

    it "should indicate that it was ~not~ created after the current time" do
      expect(subject.created_after?(time_2)).to be false
    end
  end

  context "#created_before?" do
    it "should indicate that it was created before the current time" do
      expect(subject.created_before?(time_2)).to be true
    end

    it "should indicate that it was ~not~ created before the epoch" do
      expect(subject.created_before?(time_0)).to be false
    end
  end

  context "#created_between?" do
    it "should indicate that it was created between the epoch and the current time" do
      expect(subject.created_between?(time_0, time_2)).to be true
    end
  end

  context "#created_utc" do
    it "should dig the created_utc value as a Time object" do
      expect(subject.created_utc).to eq time_1
    end
  end

  context "#inspect" do
    it "should show the permalink on inspection" do
      expect(subject.inspect).to eq "#<Brutalismbot::Reddit::Post /r/brutalism/comments/abcdef/test/>"
    end
  end

  context "#media_uri" do
    it "should return the #media_url as a URI instance" do
      allow(subject).to receive(:media_url).and_return "https://image.host/abcdef.jpg"
      expect(subject.media_uri).to eq URI.parse("https://image.host/abcdef.jpg")
    end
  end

  context "#media_url" do
    it "should return the #url" do
      allow(subject).to receive(:mime_type).and_return "image/jpeg"
      expect(subject.media_url).to eq subject.url
    end

    it "should return the preview" do
      allow(subject).to receive(:mime_type).and_return "text/html; charset=utf-8"
      expect(subject.media_url).to eq subject.data.dig("preview", "images").first.dig("source", "url")
    end
  end

  context "#mime_type" do
    it "should return value of the Content-Type header of #url" do
      stub_request(:head, subject.url).to_return(headers: {"Content-Type" => "image/jpeg"})
      expect(subject.mime_type).to eq "image/jpeg"
    end
  end

  context "#mime_type=" do
    it "should set the @mime_type" do
      subject.mime_type = "image/png"
      expect(subject.mime_type).to eq "image/png"
    end
  end

  context "#permalink" do
    it "should return the permalink" do
      expect(subject.permalink).to eq "https://reddit.com/r/brutalism/comments/abcdef/test/"
    end
  end

  context "#title" do
    it "should return the title" do
      expect(subject.title).to eq "Post to /r/brutalism"
    end
  end

  context "#to_s3" do
    it "should return the S3 put_object input" do
      expect(subject.to_s3 bucket: "brutalismbot", prefix: "data/test/posts/").to eq s3
    end
  end

  context "#to_slack" do
    it "should return the Slack message with image" do
      allow(subject).to receive(:mime_type).and_return "image/jpeg"
      expect(subject.to_slack).to eq slack_image
    end

    it "should return the Slack message with text" do
      allow(subject).to receive(:is_self?).and_return true
      expect(subject.to_slack).to eq slack_text
    end
  end

  context "#to_twitter" do
    it "should return the Twitter message" do
      allow(subject).to receive(:mime_type).and_return "image/jpeg"
      expect(subject.to_twitter).to eq twitter
    end
  end

  context "#fullname" do
    it "returns the fullname" do
      expect(subject.fullname).to eq "t3_abcdef"
    end
  end
end
