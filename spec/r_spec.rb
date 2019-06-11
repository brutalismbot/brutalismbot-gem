RSpec.describe Brutalismbot::R::Brutalism::Post do
  post = Brutalismbot::R::Brutalism::Post[JSON.parse({
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
  }.to_json)]

  it "was created after the epoch" do
    expect(post.created_after(Time.at(0))).to eq(true)
  end

  it "was ~not~ created after the current time" do
    expect(post.created_after(Time.now.utc)).to eq(false)
  end

  it "digs the created_utc value as a Time object" do
    expect(post.created_utc).to eq(Time.at(1560032174).utc)
  end

  it "digs the permalink" do
    expect(post.permalink).to eq("/r/brutalism/comments/bydae7/santuario_della_madonna_delle_lacrime_syracuse/")
  end

  it "digs the title" do
    expect(post.title).to eq("Santuario della Madonna delle Lacrime, Syracuse, Sicily, Italy")
  end

  it "converts to Slack message" do
    expect(post.to_slack).to eq({
      blocks: [
        {
          alt_text:  "Santuario della Madonna delle Lacrime, Syracuse, Sicily, Italy",
          image_url: "https://preview.redd.it/yr1325t2j7331.jpg?auto=webp&s=4bda723dce4734501279b99be1c68075e0fc722e",
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
              text: "<https://reddit.com/r/brutalism/comments/bydae7/santuario_della_madonna_delle_lacrime_syracuse/|Santuario della Madonna delle Lacrime, Syracuse, Sicily, Italy>",
              type: "mrkdwn",
            },
          ],
        },
      ]})
  end

  it "digs the url from the preview" do
    expect(post.url).to eq("https://preview.redd.it/yr1325t2j7331.jpg?auto=webp&s=4bda723dce4734501279b99be1c68075e0fc722e")
  end
end

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
    expect(Brutalismbot::R::Brutalism.new.top_post).to eq(JSON.parse(mock_response.body).dig("data", "children").first)
  end

  it "fetches new posts" do
    expect_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_response)
    expect(Brutalismbot::R::Brutalism.new.new_posts.map.to_a).to eq(JSON.parse(mock_response.body).dig("data", "children"))
  end

  it "fetches ~no~ new posts" do
    expect_any_instance_of(Net::HTTP).to receive(:request).and_return(mock_response)
    expect(Brutalismbot::R::Brutalism.new.new_posts.after(Time.at(1560032174)).first).to eq(nil)
  end
end
