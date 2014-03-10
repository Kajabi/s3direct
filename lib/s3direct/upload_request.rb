module S3Direct
  class UploadRequest
    attr_reader :path, :filename, :options

    def initialize(path, sanitized_filename, options = {})
      @path = path
      @filename = sanitized_filename
      @options = options
    end

    def key
      ::File.join(@path, @filename)
    end

    def to_json
      data = {
        url: config.bucket_url,
        filename: @filename,
        key: key,
        policy: s3_upload_policy_document,
        signature: s3_upload_signature,
        acl: s3_acl,
        success_action_status: "200",
        'AWSAccessKeyId' => config.access_key
      }

      if attachment_filename
        data["Content-Disposition"] = %Q{attachment; filename="#{attachment_filename}"}
      end

      data.to_json
    end

    def attachment_filename
      options[:attachment_filename].presence
    end

    def s3_acl
      options.fetch(:acl, config.default_acl)
    end

    private

    # generate the policy document that amazon is expecting.
    def s3_upload_policy_document
      policy = {
        'expiration' => 5.minutes.from_now.utc.xmlschema,
        'conditions' => [
          {'bucket' => config.bucket},
          {'acl' => s3_acl},
          {'success_action_status' => '200'},
          {'key' => key},
          ['content-length-range', 0, config.max_upload_size]
        ]
      }

      if attachment_filename
        policy['conditions'] << {"Content-Disposition" => %Q{attachment; filename="#{attachment_filename}"}}
      end

      encode(policy.to_json)
    end

    # sign our request by Base64 encoding the policy document.
    def s3_upload_signature
      signature = OpenSSL::HMAC.digest(
        OpenSSL::Digest::Digest.new('sha1'),
        config.secret_key,
        s3_upload_policy_document
      )
      encode(signature)
    end

    def encode(str)
      Base64.encode64(str).gsub("\n",'')
    end

    def config
      ::S3Direct.config
    end
  end
end
