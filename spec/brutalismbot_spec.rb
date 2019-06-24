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
