RSpec.describe Brutalismbot::Event::SNS do
  it "parses the SNS event" do
    msg = JSON.parse({
      Records: [
        {
          Sns: {
            Message: {
              fizz: "buzz",
            }.to_json,
          },
        },
      ],
    }.to_json)
    expect(Brutalismbot::Event::SNS[msg].map.to_a).to eq [
      {"fizz" => "buzz"},
    ]
  end
end

RSpec.describe Brutalismbot::Event::S3 do
  it "parses the S3 event" do
    msg = JSON.parse({
      Records: [
        {
          s3: {
            bucket: {
              name: "my-bucket",
            },
            object: {
              key: "path/to/my-key",
            },
          },
        },
      ],
    }.to_json)
    expect(Brutalismbot::Event::S3[msg].map.to_a).to eq [
      {
        bucket: "my-bucket",
        key:    "path/to/my-key",
      },
    ]
  end
end
