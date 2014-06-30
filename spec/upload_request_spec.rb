require 'spec_helper'

describe S3Direct::UploadRequest, '#attachment_filename' do
  it 'is nil if not provided an attachment_filename option' do
    upload_request = S3Direct::UploadRequest.new('/foo/bar', 'buzz.txt')
    expect(upload_request.attachment_filename).to be_nil
  end

  it 'is the options[:attachment_filename] if provided' do
    upload_request = S3Direct::UploadRequest.new('/foo/bar', 'random.txt', {
      attachment_filename: 'expected.txt'
    })
    expect(upload_request.attachment_filename).to eq('expected.txt')
  end
end

describe S3Direct::UploadRequest, 'the s3 upload policy' do
  before do
    S3Direct.config.stub(bucket_url: 'http://s3.com/mabucket/')
    S3Direct.config.stub(secret_key: 'sekret')
  end

  def content_length_condition(upload_request)
    policy = JSON[Base64.decode64(JSON[upload_request.to_json]['policy'])]
    policy['conditions'].detect {|c| c.is_a?(Array) && c[0] == 'content-length-range'}
  end

  it 'defaults the max upload size to the config' do
    upload_request = S3Direct::UploadRequest.new('/foo/bar', 'buzz.txt')
    expect(content_length_condition(upload_request)).to eq(['content-length-range', 0, 1073741824])
    expect(JSON[upload_request.to_json]['max_upload_size']).to eq(1073741824)
  end

  it 'uses the max_upload_size instance option if provided' do
    upload_request = S3Direct::UploadRequest.new('/foo/bar', 'buzz.txt', max_upload_size: 1024)
    expect(content_length_condition(upload_request)).to eq(['content-length-range', 0, 1024])
    expect(JSON[upload_request.to_json]['max_upload_size']).to eq(1024)
  end
end

describe S3Direct::UploadRequest, '#to_json' do
  before do
    S3Direct.config.stub(bucket_url: 'http://s3.com/mabucket/')
    S3Direct.config.stub(secret_key: 'sekret')
  end

  context "when no attachment_filename option is given" do
    before do
      upload_request = S3Direct::UploadRequest.new('/foo/bar', 'buzz.txt')
      @data = JSON[upload_request.to_json]
    end

    it "does not add a Content-Disposition attachment field" do
      expect(@data.has_key?("Content-Disposition")).to be_false
    end

    it "includes no content-disposition in the policy" do
      policy = JSON[Base64.decode64 @data['policy']]
      expect(policy['conditions'].include?('Content-Disposition')).to be_false
    end
  end

  context "when an attachment_filename option is given" do
    before do
      upload_request = S3Direct::UploadRequest.new('/foo/bar', 'buzz.txt', {
        attachment_filename: 'expected.txt'
      })
      @data = JSON[upload_request.to_json]
    end

    it "adds a Content-Disposition attachment field using the option" do
      expect(@data["Content-Disposition"]).to eq('attachment; filename="expected.txt"')
    end

    it "includes the content-disposition in the policy" do
      policy = JSON[Base64.decode64 @data['policy']]
      condition =  policy['conditions'].detect {|c| c.is_a?(Hash) && c.keys.include?('Content-Disposition') }
      expect(condition['Content-Disposition']).to eq('attachment; filename="expected.txt"')
    end
  end
end

describe S3Direct::UploadRequest, '#s3_acl' do
  it "uses the config default_acl by default" do
    upload_request = S3Direct::UploadRequest.new('/foo/bar', 'buzz.txt')
    expect(upload_request.s3_acl).to eq('public-read')
  end

  it "uses the acl option if available" do
    upload_request = S3Direct::UploadRequest.new('/foo/bar', 'buzz.txt', acl: 'authenticated-read')
    expect(upload_request.s3_acl).to eq('authenticated-read')
  end
end
