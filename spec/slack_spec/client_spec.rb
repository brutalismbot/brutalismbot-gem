RSpec.describe Brutalismbot::Slack::Client do
  let :auths do
    4.times.map{ Brutalismbot::Slack::Auth.stub }.sort{|a,b| a.team_id <=> b.team_id }
  end

  let :bucket do
    "brutalismbot"
  end

  subject do
    Brutalismbot::Slack::Client.stub auths
  end

  context "#install" do
    let(:key)  { subject.key_for auths.first }
    let(:body) { auths.first.to_json }

    it "should add an auth object to storage" do
      expect_any_instance_of(Aws::S3::Client).to receive(:put_object).with(
        bucket: bucket,
        key:    key,
        body:   body,
      )
      subject.install(auths.first)
    end
  end

  context "#key_for" do
    it "should return the key for a post" do
      expect(subject.key_for auths.first).to eq File.join(subject.prefix, auths.first.path)
    end
  end

  context "#get" do
    it "should return an auth" do
      expect(subject.get(key: subject.key_for(auths.first)).path).to eq auths.first.path
    end
  end

  context "#list" do
    it "should return a prefix listing" do
      expect(subject.list.map(&:path)).to eq auths.map(&:path)
    end
  end

  context "#push" do
    let(:auth) { Brutalismbot::Slack::Auth.stub }
    let(:post) { Brutalismbot::Reddit::Post.stub }

    let :ok do
      sock = Net::BufferedIO.new StringIO.new <<~EOS.rstrip
        HTTP/1.1 204 No Content\r
        Connection: close\r
        Content-Length: 0\r
      EOS
      Net::HTTPResponse.read_new(sock)
    end

    let :err do
      sock = Net::BufferedIO.new StringIO.new <<~EOS.rstrip
        HTTP/1.1 404 Not Found\r
        Connection: close\r
        Content-Length: #{"no_active_hooks".bytesize}
        \r
        no_active_hooks
      EOS
      Net::HTTPResponse.read_new(sock).tap {|r| r.reading_body(sock, true) {} }
    end

    before do
      allow_any_instance_of(Brutalismbot::Slack::Auth).to receive(:push).and_return ok
    end

    it "should push a post to the workspace" do
      expect_any_instance_of(Net::HTTP).to receive(:request).and_return ok
      expect(subject.push(post, webhook_urls: [auth.webhook_url])).to eq [ok]
    end

    it "should recover from an HTTP error" do
      expect_any_instance_of(Net::HTTP).to receive(:request).and_return err
      expect(subject.push(post, webhook_urls: [auth.webhook_url])).to eq [err]
    end

    it "should NOT push a post to the workspace" do
      expect_any_instance_of(Net::HTTP).not_to receive(:request)
      subject.push post, webhook_urls: [auth.webhook_url], dryrun: true
    end
  end

  context "#uninstall" do
    let(:key)  { subject.key_for auths.first }
    let(:body) { auths.first.to_json }

    it "should remove an auth from storage" do
      expect(subject.uninstall(auths.first).map(&:to_h)).to eq [
        version_id: subject.key_for(auths.first),
      ]
    end
  end
end
