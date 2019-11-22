RSpec.describe Brutalismbot::Base do
  let(:item) { {fizz: "buzz"} }

  context "::parse" do
    it "should parse a JSON string into @item" do
      expect(Brutalismbot::Base.parse(item.to_json).to_h).to eq("fizz" => "buzz")
    end
  end
end
