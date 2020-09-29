RSpec.describe Brutalismbot::Reddit::Post do
  let(:time_0) { Time.at 1234567000 }
  let(:time_1) { Time.at 1234567890 }
  let(:time_2) { Time.at 1234567900 }

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

  context "#fullname" do
    it "returns the fullname" do
      expect(subject.fullname).to eq "t3_abcdef"
    end
  end

  context "#inspect" do
    it "should show the permalink on inspection" do
      expect(subject.inspect).to eq "#<Brutalismbot::Reddit::Post /r/brutalism/comments/abcdef/test/>"
    end
  end

  context "#is_gallery?" do
    it "should return true" do
      subject.data["is_gallery"] = true
      expect(subject.is_gallery?).to be true
    end

    it "should return false" do
      expect(subject.is_gallery?).to be false
    end
  end

  context "#is_self?" do
    it "should return true" do
      subject.data["is_self"] = true
      expect(subject.is_self?).to be true
    end

    it "should return false" do
      expect(subject.is_self?).to be false
    end
  end

  context "#media_urls" do
    it "should return the gallery URLs" do
      subject.data["is_gallery"] = true
      expect(subject.media_urls).to eq %w[https://preview.image.host/abcdef_1.jpg https://preview.image.host/abcdef_2.jpg]
    end

    it "should return the preview URLs" do
      expect(subject.media_urls).to eq %w[https://preview.image.host/abcdef_large.jpg]
    end

    it "should return an empty list" do
      subject.data.delete "preview"
      expect(subject.media_urls.empty?).to be true
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
end
