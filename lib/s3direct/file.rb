module S3Direct
  class File

    attr_reader :model, :identifier, :pattern

    def self.sanitize_filename(name)
      name.strip
    end

    def initialize(model, identifier, pattern, opts={})
      setup_options opts

      @model = model
      @identifier = identifier
      @pattern = pattern
    end

    def name
      @model.send "#{identifier}_file"
    end

    def s3_path
      StringInterpolator.new(model, pattern).to_s
    end

    def url
      if exists?
        ::File.join(config.bucket_url, key)
      else
        default_url
      end
    end

    def upload_request(filename = name)
      if filename.blank?
        raise "Can't create an upload request without a filename - " +
          "provide it as an argument or set #{identifier}_file on the model"
      end
      UploadRequest.new s3_path, self.class.sanitize_filename(filename)
    end

    def key
      ::File.join(s3_path, name)
    end

    def exists?
      name.present?
    end

    private

    def config
      ::S3Direct.config
    end

    def options
      # set up any defaults here
      @options ||= {}
    end

    def setup_options(opts)
      options.merge! opts
    end

    def default_url
      options[:default_url]
    end

  end
end
