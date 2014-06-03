module S3Direct
  class File

    attr_reader :model, :identifier, :pattern, :options

    def self.sanitize_filename(name)
      unless name.nil?
        name.strip
      end
    end

    def initialize(model, identifier, pattern, opts={})
      @model = model
      @identifier = identifier
      @pattern = pattern

      @options = default_options.merge(opts)
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

    def upload_request(filename = name, opts = {})
      if filename.blank?
        raise "Can't create an upload request without a filename - " +
          "provide it as an argument or set #{identifier}_file on the model"
      end
      UploadRequest.new s3_path, self.class.sanitize_filename(filename), options.merge(opts)
    end

    def key
      ::File.join(s3_path, name)
    end

    def exists?
      name.present?
    end

    def max_upload_size
      max_method = "#{identifier}_max_upload_size"

      if model.respond_to?(max_method)
        model.public_send(max_method)
      end
    end

    private

    def config
      ::S3Direct.config
    end

    def default_options
      Hash.new.tap do |h|
        h[:max_upload_size] = max_upload_size if max_upload_size
      end
    end

    def default_url
      options[:default_url]
    end

  end
end
