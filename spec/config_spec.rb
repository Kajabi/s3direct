require 'spec_helper'

describe S3Direct::Config do
  it "has a default_acl of public-read when not set" do
    expect(S3Direct.config.default_acl).to eq('public-read')
  end

  it "allows setting a default_acl" do
    begin
      S3Direct.configure {|c| c.default_acl = 'authenticated-read' }
      expect(S3Direct.config.default_acl).to eq('authenticated-read')
    ensure
      S3Direct.configure {|c| c.default_acl = nil }
    end
  end
end
