RSpec.describe Brutalismbot::S3::Client do
  context "#bucket" do
    it "should return an instance of Aws::S3::Bucket" do
      expect(subject.bucket.class).to be Aws::S3::Bucket
    end
  end
end
