RSpec.describe Brutalismbot::S3::Client do
  client = Brutalismbot::S3::Client.new bucket: nil

  it "gets an instance of R::Brutalism" do
    expect(client.subreddit.class).to eq(R::Brutalism)
  end

  it "gets an instance of R::Brutalism with the correct endpoint" do
    expect(client.subreddit.endpoint).to eq("https://www.reddit.com/r/brutalism")
  end

  it "gets an instance of R::Brutalism with the correct user agent" do
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
  s3      = Aws::S3::Client.new stub_responses: true
  bucket  = Aws::S3::Bucket.new client: s3, name: "my-bucket"
  auths   = Brutalismbot::S3::AuthCollection.new bucket: bucket, prefix: "my/prefix/"
  authmap = {
    "#{auths.prefix}team=T1234ABCD/channel=C1234ABCD/oauth.json" => auth(team_id: "T1234ABCD"),
    "#{auths.prefix}team=TABCD1234/channel=CABCD1234/oauth.json" => auth(team_id: "TABCD1234"),
  }
  s3.stub_responses :list_objects, -> (context) do
    {
      contents: authmap.keys.select do |key|
        key.start_with? context.params[:prefix]
      end.map do |key|
        {key: key}
      end
    }
  end
  s3.stub_responses :get_object, -> (context) do
    {body: authmap[context.params[:key]].to_json}
  end
  s3.stub_responses :delete_object
  s3.stub_responses :put_object


  it "#each" do
    expect(auths.to_a).to eq(authmap.values)
  end

  it "#delete" do
  end

  it "#delete [DRYRUN]" do
    expect(auths.delete team_id: "T1234ABCD", dryrun: true).to eq([nil])
  end

  it "#put" do
    # newauth = Brutalismbot::OAuth[auth(team_id: "TFIZZBUZZ")]
    # exp     = "#{auths.prefix}team=#{newauth.team_id}/channel=#{newauth.channel_id}/oauth.json"
    # expect(auths.put(auth: newauth).key).to eq(exp)
  end

  it "#put [DRYRUN]" do
    # newauth = Brutalismbot::OAuth[auth(team_id: "TFIZZBUZZ")]
    # expect(auths.put auth: newauth, dryrun: true).to eq(nil)
  end
end

RSpec.describe Brutalismbot::S3::PostCollection do
  s3      = Aws::S3::Client.new stub_responses: true
  bucket  = Aws::S3::Bucket.new client: s3, name: "my-bucket"
  posts   = Brutalismbot::S3::PostCollection.new bucket: bucket, prefix: "my/prefix/"
  postmap = {
    "#{posts.prefix}year=2019/month=2019-06/day=2019-06-09/1560115697.json" => {"created_utc" => 1560115697},
    "#{posts.prefix}year=2019/month=2019-06/day=2019-06-09/1560116759.json" => {"created_utc" => 1560116759},
  }
  s3.stub_responses :list_objects, -> (context) do
    {
      contents: postmap.keys.select do |key|
        key.start_with? context.params[:prefix]
      end.map do |key|
        {key: key}
      end
    }
  end
  s3.stub_responses :get_object, -> (context) do
    {body: postmap[context.params[:key]].to_json}
  end
  s3.stub_responses :delete_object
  s3.stub_responses :put_object

  it "#each" do
    expect(posts.to_a).to eq(postmap.values)
  end

  it "#latest" do
    expect(posts.latest).to eq(postmap.max.last)
  end

  it "#max_key" do
    expect(posts.max_key.key).to eq(postmap.keys.max)
  end

  it "#max_time" do
    expect(posts.max_time).to eq(postmap.max.last["created_utc"])
  end

  it "#prefix_for" do
    time = Time.parse "2019-06-09 12:34:56Z"
    exp  = "#{posts.prefix}year=2019/month=2019-06/day=2019-06-09/"
    expect(posts.prefix_for time: time).to eq(exp)
  end

  it "#put" do
  end
end
