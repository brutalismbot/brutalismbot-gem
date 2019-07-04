RSpec.describe Brutalismbot::Post do
  post = Brutalismbot::Post[{
    "data" => {
      "created_utc" => 1560032174,
      "permalink"   => "/r/brutalism/comments/bydae7/santuario_della_madonna_delle_lacrime_syracuse/",
      "title"       => "Santuario della Madonna delle Lacrime, Syracuse, Sicily, Italy",
      "url"         => "https://i.redd.it/yr1325t2j7331.jpg",
      "preview" => {
        "images" => [
          {
            "source" => {
              "url"    => "https://preview.redd.it/yr1325t2j7331.jpg?auto=webp&amp;s=4bda723dce4734501279b99be1c68075e0fc722e",
              "width"  => 3456,
              "height" => 4608
            },
          },
          {
            "source" => {
              "url"    => "https://preview.redd.it/yr1325t2j7331.jpg?auto=webp&amp;s=4bda723dce4734501279b99be1c68075e0fc722e",
              "width"  => 3456,
              "height" => 4608
            },
          },
        ],
      },
    },
  }]

  it "was created after the epoch" do
    expect(post.created_after?(Time.at(0))).to eq(true)
  end

  it "was ~not~ created after the current time" do
    expect(post.created_after?(Time.now.utc)).to eq(false)
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

  it "digs the url from metadata" do
    post = Brutalismbot::Post[{
      "data" => {
        "media_metadata" => {
          "?": {
              "s" => {
                "u" => "https://example.com"
              }
          }
        }
      }
    }]
    expect(post.url).to eq("https://example.com")
  end
end
