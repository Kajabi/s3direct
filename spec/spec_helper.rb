require 'rspec'
require_relative '../lib/s3direct'

S3Direct.configure do |config|
  config.bucket_url = "http://example.com"
end
