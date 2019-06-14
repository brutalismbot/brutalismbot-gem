RSpec.describe Brutalismbot::R::Brutalism do
  mock_response = OpenStruct.new body: {
    data: {
      children: [
        {
          data: {
            created_utc: 1560032174,
            permalink:   "/r/brutalism/comments/bydae7/santuario_della_madonna_delle_lacrime_syracuse/",
            title:       "Santuario della Madonna delle Lacrime, Syracuse, Sicily, Italy",
            url:         "https://i.redd.it/yr1325t2j7331.jpg",
            preview: {
              images: [
                {
                  source: {
                    url:    "https://preview.redd.it/yr1325t2j7331.jpg?auto=webp&amp;s=4bda723dce4734501279b99be1c68075e0fc722e",
                    width:  3456,
                    height: 4608
                  },
                },
              ],
            },
          },
        },
      ],
    },
  }.to_json

  it "fetches the top post" do
    expect_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_response)
    ret = Brutalismbot::R::Brutalism.new.posts(:top).first
    exp = Brutalismbot::Post.new JSON.parse(mock_response.body).dig("data", "children").first
    expect(ret).to eq(exp)
  end

  it "fetches new posts" do
    expect_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_response)
    ret = Brutalismbot::R::Brutalism.new.posts(:new).to_a
    exp = JSON.parse(mock_response.body).dig("data", "children").map do |x|
      Brutalismbot::Post.new x
    end
    expect(ret).to eq(exp)
  end

  it "fetches ~no~ new posts" do
    expect_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_response)
    expect(Brutalismbot::R::Brutalism.new.posts(:new).since(time: Time.at(1560032174)).first).to eq(nil)
  end
end
