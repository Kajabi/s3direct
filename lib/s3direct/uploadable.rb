module S3Direct
  module Uploadable

    def has_s3_file(attr_name, pattern, options={})
      define_method attr_name do
        ::S3Direct::File.new(self, attr_name, pattern, options)
      end
      define_method "#{attr_name}_file=" do |filename|
        self["#{attr_name}_file"] = ::S3Direct::File.sanitize_filename(filename)
      end
    end

  end
end
