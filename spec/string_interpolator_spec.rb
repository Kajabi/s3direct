require "spec_helper"
require "ostruct"

describe S3Direct::StringInterpolator do

  it "converts :pattern tags using local context methods" do
    foo = OpenStruct.new(bar: "bar", fizz: "fizzy", buzz: "buzz_buzz")
    interpolation = S3Direct::StringInterpolator.new(foo, "foo/bar/:bar/fizz/:fizz/buzz/:buzz/:class")
    expect(interpolation.to_s).to eq "foo/bar/bar/fizz/fizzy/buzz/buzz_buzz/open_struct"
  end

  it "will not re-interpolate :pattern returned from method calls" do
    o = OpenStruct.new
    o.security = ":test"
    o.test = "boom"
    interpolation = S3Direct::StringInterpolator.new(o, "/security/:security")
    expect(interpolation.to_s).to eq '/security/:test'
  end

end
