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
    expect(auth.post(body: {fizz: "buzz"}.to_json, dryrun: true).code).to eq("204")
  end
end
