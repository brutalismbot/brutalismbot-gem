RSpec.describe Brutalismbot::S3::Prefix do
  let(:client) { Aws::S3::Client.new stub_responses: true }
  let(:bucket) { Aws::S3::Bucket.new(name: "brutalismbot", client: client) }
  let(:prefix) { bucket.objects(prefix: "data/test/") }

  subject do
    Brutalismbot::S3::Prefix.new(prefix) do |object|
      JSON.parse object.get.body.read
    end
  end

  before do
    client.stub_responses :list_objects, -> (context) {
      {
        contents: [
          {key: "data/test/1"},
          {key: "data/test/2"},
          {key: "data/test/3"},
        ]
      }
    }

    client.stub_responses :get_object, -> (context) {
      {
        body: StringIO.new({fizz: "buzz"}.to_json)
      }
    }
  end

  context "#all" do
    it "should iterate over the bucket prefix" do
      expect(subject.all).to eq [
        {"fizz" => "buzz"},
        {"fizz" => "buzz"},
        {"fizz" => "buzz"},
      ]
    end
  end

  context "#last" do
    it "should get the last object" do
      expect(subject.last).to eq "fizz" => "buzz"
    end
  end
end
