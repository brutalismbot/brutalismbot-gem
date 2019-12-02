RSpec.describe Brutalismbot::Reddit::Post do
  let(:time_0) { Time.at 1234567000 }
  let(:time_1) { Time.at 1234567890 }
  let(:time_2) { Time.at 1234567900 }

  let :slack_image do
    {
      blocks: [
        {
          alt_text:  "Post to /r/brutalism",
          image_url: "https://preview.redd.it/abcdef.jpg",
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
    <<~EOS.strip
      Post to /r/brutalism
      https://reddit.com/r/brutalism/comments/abcdef/test/
    EOS
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

  context "#to_slack" do
    it "should return the Slack message with image" do
      expect(subject.to_slack).to eq slack_image
    end

    it "should return the Slack message with text" do
      allow(subject).to receive(:url).and_return nil
      expect(subject.to_slack).to eq slack_text
    end
  end

  context "#to_twitter" do
    it "should return the Twitter message" do
      expect(subject.to_twitter).to eq twitter
    end
  end

  context "#url" do
    let :metapost do
      Brutalismbot::Reddit::Post.new(
        "data" => {
          "media_metadata" => {
            "?": {
              "s" => {
                "u" => "https://example.com",
              },
            },
          },
        },
      )
    end

    it "should returns the url from the preview" do
      expect(subject.url).to eq "https://preview.redd.it/abcdef.jpg"
    end

    it "should return url from metadata" do
      expect(metapost.url).to eq("https://example.com")
    end
  end

  context "#fullname" do
    it "returns the fullname" do
      expect(subject.fullname).to eq "t3_abcdef"
    end
  end
end
