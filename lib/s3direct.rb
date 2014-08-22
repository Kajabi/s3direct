require "active_support/all"

require "s3direct/version"
require "s3direct/content_type_detection"
require "s3direct/file"
require "s3direct/string_interpolator"
require "s3direct/upload_request"
require "s3direct/uploadable"


module S3Direct
  def self.configure
    yield config
  end

  def self.config
    @@config ||= Config.new
  end

  class Config
    attr_accessor :bucket
    attr_accessor :bucket_url
    attr_accessor :access_key
    attr_accessor :secret_key

    attr_writer :max_upload_size
    def max_upload_size
      @max_upload_size ||= 1.gigabyte
    end

    attr_writer :default_acl
    def default_acl
      @default_acl ||= 'public-read'
    end
  end

  begin
    class Engine < Rails::Engine
    end
  rescue NameError => e
    puts "Rails is not loaded => #{e.message}"
  end
end
