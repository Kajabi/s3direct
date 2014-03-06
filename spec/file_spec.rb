require 'spec_helper'

describe S3Direct::File do

  it "mounts to an activerecord model on initialize" do
    model = double(:model)
    file = S3Direct::File.new(model, :my_file, "foo/bar/bat")

    expect(file.model).to eql model
    expect(file.identifier).to eql :my_file
    expect(file.pattern).to eql "foo/bar/bat"
  end

  it "interpolates an s3 path based on the pattern given" do
    model = double(:model, lesson_id: 1, id: 2)
    file = S3Direct::File.new(model, :my_file, "lessons/:lesson_id/videos/:id")

    expect(file.s3_path).to eql "lessons/1/videos/2"
  end

  it "allows a default url to used when a file is not present" do
    model = double(:model, lesson_id: 1, id: 2, media_file: nil)
    file = S3Direct::File.new(model, :media, "lessons/:lesson_id/videos/:id", default_url: "http://example.com/default.png")
    expect(file.url).to eql "http://example.com/default.png"
    model.stub(media_file: "foo.png")
    expect(file.url).to_not eql "http://example.com/default.png"
  end

end

describe S3Direct::File, "#exists?" do

  it "is true if the models '{name}_file' is not nil" do
    model = double :model, media_file: "foobar.png"
    file = S3Direct::File.new(model, :media, "foo/bar/bat")
    expect(file.exists?).to be true
  end

  it "is false if the models '{name}_file' is nil" do
    model = double :model, media_file: nil
    file = S3Direct::File.new(model, :media, "foo/bar/bat")
    expect(file.exists?).to be false
  end
end

describe S3Direct::File, "#upload_request" do

  it "returns a s3 direct upload object" do
    model = double(:model, media_file: 'foo')
    file = S3Direct::File.new(model, :media, "foo/bar/bat")

    expect(file.upload_request).to be_an_instance_of(S3Direct::UploadRequest)
    expect(file.upload_request.key).to eql(file.key)
  end

  it "accepts the filename as a parameter and sanitizes it" do
    model = double(:model)
    file = S3Direct::File.new(model, :media, "foo/bar/bat")
    expect(file.upload_request('  foo').filename).to eql 'foo'
  end

  it "optionally receives options to pass to the UploadRequest" do
    model = double(:model)
    file = S3Direct::File.new(model, :media, "foo/bar/bat")
    S3Direct::UploadRequest.should_receive(:new).with(anything, "test.txt", {foo: 'bar'})
    file.upload_request('test.txt', {foo: 'bar'})
  end

  it "raises an error if the filename is not set or provided" do
    model = double(:model)
    file = S3Direct::File.new(model, :media, "foo/bar/bat")
    expect { file.upload_request }.to raise_error
  end

end

describe S3Direct::File, "#name" do
  it "returns the file name based on the pattern: '<name>_file'" do
    model = double(:model)
    model.stub(:avatar_file) { "my_avatar.png" }
    file = S3Direct::File.new(model, :avatar, "")

    expect(file.name).to eql "my_avatar.png"
  end
end

describe S3Direct::File, "#url" do
  context "the file exists" do
    it "returns the full url of the file" do
      S3Direct.config.stub(bucket_url: 'http://s3.com/mabucket/')
      model = double(:model, id: 77, avatar_file: 'my_avatar.png')
      file = S3Direct::File.new(model, :avatar, "my_model/:id/avatar")

      expect(file.url).to eql "http://s3.com/mabucket/my_model/77/avatar/my_avatar.png"
    end
  end

  context "the file does not exist" do
    it "returns nil" do
      model = double(:model)
      model.stub(:avatar_file) { nil }
      file = S3Direct::File.new(model, :avatar, "foo/bar/bat")

      expect(file.url).to be_nil
    end
  end
end

describe S3Direct::File, "#key" do
  it "returns the full s3 key for the file" do
    model = double(:model)
    model.stub(:id) { 77 }
    model.stub(:avatar_file) { "my_avatar.png" }
    file = S3Direct::File.new(model, :avatar, "my_model/:id/avatar/")

    expect(file.key).to eql "my_model/77/avatar/my_avatar.png"
  end
end
