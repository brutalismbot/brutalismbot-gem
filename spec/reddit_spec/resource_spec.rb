RSpec.describe Brutalismbot::Reddit::Resource do
  include WebMock

  let :posts do
    25.times.map{ Brutalismbot::Reddit::Post.stub }
  end

  subject do
    Brutalismbot::Reddit::Resource.new uri: "https://www.reddit.com/r/brutalism/top.json"
  end

  context "#all" do
    it "should return all the posts" do
      stub_request(:get, "https://www.reddit.com/r/brutalism/top.json").to_return(body: {data: {children: posts}}.to_json)
      expect(subject.all.map(&:to_h)).to eq posts.map(&:to_h)
    end
  end

  context "#last" do
    it "should" do
      stub_request(:get, "https://www.reddit.com/r/brutalism/top.json").to_return(body: {data: {children: posts}}.to_json)
      expect(subject.last.to_h).to eq posts.last.to_h
    end
  end
end
