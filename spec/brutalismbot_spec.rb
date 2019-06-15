RSpec.describe Brutalismbot do
  it "has a version number" do
    expect(Brutalismbot::VERSION).not_to be nil
  end

  it "can set the config" do
    Brutalismbot.config = {fizz: "buzz"}
    expect(Brutalismbot.config).to eq({fizz: "buzz"})
  end

  it "can unset the config" do
    Brutalismbot.config = nil
    expect(Brutalismbot.config).to eq({})
  end

  it "can set the logger" do
    logger = Logger.new(STDOUT)
    Brutalismbot.logger = logger
    expect(Brutalismbot.logger).to eq(logger)
  end

  it "can unset the logger" do
    Brutalismbot.config.delete :logger
    expect(Brutalismbot.logger).to eq(Brutalismbot.class_variable_get :@@logger)
  end
end

RSpec.describe Brutalismbot::Auth do

  auth = Brutalismbot::Auth[JSON.parse({
    ok:           true,
    access_token: "<token>",
    scope:        "identify,incoming-webhook",
    user_id:      "UABCD1234",
    team_name:    "My Slack Workspace",
    team_id:      "TABCD1234",
    incoming_webhook: {
      channel:           "#brutalism",
      channel_id:        "CABCD1234",
      configuration_url: "https://workspace.slack.com/services/BABCD1234",
      url:               "https://hooks.slack.com/services/TABCD1234/BABCD1234/1234567890abcdef12345678",
    },
    scopes: [
      "identify",
      "incoming-webhook",
    ],
  }.to_json)]

  it "reads the channel_id" do
    expect(auth.channel_id).to eq("CABCD1234")
  end

  it "reads the team_id" do
    expect(auth.team_id).to eq("TABCD1234")
  end

  it "reads the webhook_url" do
    expect(auth.webhook_url).to eq("https://hooks.slack.com/services/TABCD1234/BABCD1234/1234567890abcdef12345678")
  end

  it "posts the http body" do
    expect_any_instance_of(Net::HTTP).to receive(:request).and_return('OK')
    expect(auth.post(body: {fizz: "buzz"}.to_json)).to eq('OK')
  end

  it "posts the http body [DRYRUN]" do
    expect(auth.post(body: {fizz: "buzz"}.to_json, dryrun: true)).to eq(true)
  end
end

RSpec.describe Brutalismbot::Post do
  post = Brutalismbot::Post.new({
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
  })

  it "was created after the epoch" do
    expect(post.created_after(time: Time.at(0))).to eq(true)
  end

  it "was ~not~ created after the current time" do
    expect(post.created_after(time: Time.now.utc)).to eq(false)
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
    post = Brutalismbot::Post.new({
      "data" => {
        "media_metadata" => {
          "?": {
              "s" => {
                "u" => "https://example.com"
              }
          }
        }
      }
    })
    expect(post.url).to eq("https://example.com")
  end
end
