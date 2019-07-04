RSpec.describe Brutalismbot::S3::Client do
  client = Brutalismbot::S3::StubClient.new bucket: "my-bucket", prefix: "my/prefix/"

  it "gets an instance of Brutalismbot::R::Brutalism" do
    expect(client.subreddit.class).to eq(Brutalismbot::R::Brutalism)
  end

  it "gets an instance of Brutalismbot::R::Brutalism with the correct endpoint" do
    expect(client.subreddit.endpoint).to eq("https://www.reddit.com/r/brutalism")
  end

  it "gets an instance of Brutalismbot::R::Brutalism with the correct user agent" do
    expect(client.subreddit.user_agent).to eq("Brutalismbot #{Brutalismbot::VERSION}")
  end

  it "gets an AuthCollection" do
    expect(client.auths.class).to eq(Brutalismbot::S3::AuthCollection)
  end

  it "gets a PostCollection" do
    expect(client.posts.class).to eq(Brutalismbot::S3::PostCollection)
  end
end

def auth(options = {})
  JSON.parse({
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
  }.merge(options).to_json)
end

RSpec.describe Brutalismbot::S3::AuthCollection do
  client = Brutalismbot::S3::StubClient.new(bucket: "my-bucket", prefix: "my/prefix/")
  auths  = client.auths

  it "#each" do
    expect(auths.to_a).to eq(client.instance_variable_get :@auths)
  end

  it "#delete" do
    auth = auths.first
    exp = Aws::S3::Types::DeleteObjectOutput.new delete_marker:   false,
                                                 version_id:      "ObjectVersionId",
                                                 request_charged: "RequestCharged"
    expect(auths.delete auth).to eq(exp)
  end

  it "#mirror" do
    stub_url = /hooks.slack.com\/services\/.*/
    stub_request(:post, stub_url).to_return(body: "ok", status: 200)
    expect(auths.mirror(client.posts.last).map(&:body)).to eq(["ok"] * auths.count)
  end

  it "#put" do
    newauth = Brutalismbot::Auth[auth(team_id: "TFIZZBUZZ")]
    exp     = "#{auths.prefix}team=#{newauth.team_id}/channel=#{newauth.channel_id}/oauth.json"
    expect(auths.put(newauth).key).to eq(exp)
  end
end

RSpec.describe Brutalismbot::S3::PostCollection do
  client = Brutalismbot::S3::StubClient.new(bucket: "my-bucket", prefix: "my/prefix/")
  posts  = client.posts

  it "#each" do
    expect(posts.to_a).to eq(client.instance_variable_get :@posts)
  end

  it "#last" do
    expect(posts.last).to eq(client.instance_variable_get(:@posts).last)
  end

  it "#pull" do
    stub_url   = /www.reddit.com\/r\/brutalism\/new.json.*?/
    stub_body  = {data: {children: client.posts.all.map(&:to_h)}}
    exp        = client.posts.map{|x| posts.key_for x }
    stub_request(:get, stub_url).to_return(body: stub_body.to_json)
    expect(posts.pull.map(&:key)).to eq(exp)
  end

  it "#put" do
    newpost = Brutalismbot::Post["data" => {"created_utc" => 1560116759}]
    exp     = "#{posts.prefix}year=2019/month=2019-06/day=2019-06-09/1560116759.json"
    expect(posts.put(newpost).key).to eq(exp)
  end
end
