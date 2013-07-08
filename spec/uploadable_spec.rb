require "spec_helper"

module TestS3Uploadable
  class Base
  end

  Base.extend S3Direct::Uploadable

  class Foo < Base
    has_s3_file :avatar, "foo/:id/avatar", default_url: "foobar.png"

    def avatar_file
      "avatar.png"
    end

    def id
      42
    end
  end

end

describe S3Direct::Uploadable, "#has_file" do
  it "defines a method on the object to access the file" do
    foo = TestS3Uploadable::Foo.new
    expect(foo.avatar).to be_kind_of(S3Direct::File)
    expect(foo.avatar.s3_path).to eql "foo/42/avatar"
  end

  it "allows for default urls" do
    foo = TestS3Uploadable::Foo.new
    foo.stub(:avatar_file) { nil }
    expect(foo.avatar.url).to eql "foobar.png"
  end
end
