RSpec.describe Brutalismbot::Logger do
  let(:stderr) { Logger.new(STDERR) }

  subject { Brutalismbot.logger }

  context "#logger" do
    it "should return the logger" do
      expect(subject).not_to be nil
    end
  end

  context "#logger=" do
    after { Brutalismbot.logger = ::Logger.new(File::NULL) }

    it "should set the logger" do
      Brutalismbot.logger = stderr
      expect(subject).to be stderr
    end
  end
end
