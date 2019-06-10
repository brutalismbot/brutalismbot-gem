RSpec.describe Brutalismbot::S3::Client do
  client = Brutalismbot::S3::Client.new bucket: nil

  it "gets an instance of R::Brutalism" do
    expect(client.subreddit.class).to eq(R::Brutalism)
  end

  it "gets an instance of R::Brutalism with the correct endpoint" do
    expect(client.subreddit.endpoint).to eq("https://www.reddit.com/r/brutalism")
  end

  it "gets an instance of R::Brutalism with the correct user agent" do
    expect(client.subreddit.user_agent).to eq("Brutalismbot 0.1.1")
  end

  it "gets an AuthCollection" do
    expect(client.auths.class).to eq(Brutalismbot::S3::AuthCollection)
  end

  it "gets a PostCollection" do
    expect(client.posts.class).to eq(Brutalismbot::S3::PostCollection)
  end
end


RSpec.describe Brutalismbot::S3::AuthCollection do
  s3     = Aws::S3::Client.new
  prefix = "my/prefix/"
  auth   = {
    ok:           true,
    access_token: "<token>",
    scope:        "identify,incoming-webhook",
    user_id:      "U1234ABCD",
    team_name:    "My Team",
    team_id:      "T1234ABCD",
    incoming_webhook: {
      channel:           "#brutalism",
      channel_id:        "C1234ABCD",
      configuration_url: "https://my-team.slack.com/services/B1234ABCD",
      url:               "https://hooks.slack.com/services/T1234ABCD/B1234ABCD/1234567890abcdef12345678",
    },
    scopes: [
      "identify",
      "incoming-webhook",
    ],
  }
  s3.stub_responses :list_objects, contents: [
    {key: "#{prefix}team=T1234ABCD/channel=C1234ABCD/oauth.json"},
    {key: "#{prefix}team=TABCD1234/channel=CABCD1234/oauth.json"},
  ]
  s3.stub_responses :get_object, body: auth.to_json

  bucket = Aws::S3::Bucket.new client: s3, name: "my-bucket"

  it "stubs AWS" do
    expect(bucket.objects(prefix: "my/prefix/").map &:key).to eq([
      "#{prefix}team=T1234ABCD/channel=C1234ABCD/oauth.json",
      "#{prefix}team=TABCD1234/channel=CABCD1234/oauth.json",
    ])
  end

  it "returns each auth" do
    auths = Brutalismbot::S3::AuthCollection.new bucket: bucket, prefix: prefix
    expect(auths.to_a).to eq([auth, auth].map(&:to_json).map{|x| JSON.parse x })
  end
end

RSpec.describe Brutalismbot::S3::PostCollection do
  s3     = Aws::S3::Client.new
  prefix = "my/prefix/"
  post   = {}
  s3.stub_responses :list_objects, contents: [
    {key: "#{prefix}year=2019/month=2019-06/day=2019-06-09/1560116759.json"},
    {key: "#{prefix}year=2019/month=2019-06/day=2019-06-09/1560115697.json"},
  ]
  s3.stub_responses :get_object, body: post.to_json

  bucket = Aws::S3::Bucket.new client: s3, name: "my-bucket"

  it "returns each post" do
    posts = Brutalismbot::S3::PostCollection.new bucket: bucket, prefix: prefix
    expect(posts.to_a).to eq([post, post].map(&:to_json).map{|x| JSON.parse x })
  end
end
