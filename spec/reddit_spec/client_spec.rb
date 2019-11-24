RSpec.describe Brutalismbot::Reddit::Client do
  subject { Brutalismbot::Reddit::Client.new }

  context "#list" do
    let(:uri) { "https://www.reddit.com/r/brutalism/top.json" }

    it "should return list resource" do
      expect(subject.list(:top).class).to eq Brutalismbot::Reddit::Resource
    end

    it "should return a URI to the top resource " do
      expect(subject.list(:top, limit: 10).uri).to eq "#{uri}?limit=10"
    end
  end
end
