RSpec.describe Brutalismbot::R::Brutalism do
  subreddit = Brutalismbot::R::Brutalism.new
  posts     = 3.times.map{ Brutalismbot::Post.stub }.sort{|a,b| b.created_utc <=> a.created_utc }

  it "fetches the top post" do
    stub_url  = "https://www.reddit.com/r/brutalism/top.json"
    stub_body = {data: {children: posts.map(&:to_h)}}
    stub_request(:get, stub_url).to_return(body: stub_body.to_json)
    expect(subreddit.posts(:top).all).to eq(posts)
  end

  it "fetches new posts" do
    stub_url  = "https://www.reddit.com/r/brutalism/new.json"
    stub_body = {data: {children: posts.map(&:to_h)}}
    stub_request(:get, stub_url).to_return(body: stub_body.to_json)
    expect(subreddit.posts(:new).all).to eq(posts)
  end

  it "fetches the last post" do
    stub_url  = "https://www.reddit.com/r/brutalism/new.json"
    stub_body = {data: {children: posts}}
    stub_request(:get, stub_url).to_return(body: stub_body.to_json)
    expect(subreddit.posts(:new).last).to eq(posts.last)
  end

  it "fetches ~1~ new post" do
    stub_url  = "https://www.reddit.com/r/brutalism/new.json"
    stub_body = {data: {children: posts}}
    stub_request(:get, stub_url).to_return(body: stub_body.to_json)
    time = stub_body[:data][:children].map{|x| x.dig "data", "created_utc" }.max
    expect(subreddit.posts(:new).since(time - 1).count).to eq(1)
  end

  it "fetches ~no~ new posts" do
    stub_url  = "https://www.reddit.com/r/brutalism/new.json"
    stub_body = {data: {children: posts}}
    stub_request(:get, stub_url).to_return(body: stub_body.to_json)
    time = stub_body[:data][:children].map{|x| x.dig "data", "created_utc" }.max
    expect(subreddit.posts(:new).since(time).count).to eq(0)
  end
end
