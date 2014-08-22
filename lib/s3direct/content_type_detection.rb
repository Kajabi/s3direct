require "mime-types"

module S3Direct
  class ContentTypeDetection < Struct.new(:filename, :filetype)
    class Default
      def self.content_type
        'binary/octet-stream'.dup
      end
    end

    def lookup
      type = if filetype.to_s.empty?
        FilenameStrategy.new(filename).lookup
      else
        HybridStrategy.new(filename, filetype).lookup
      end

      remap(type)
    end

    def remap(type)
      mappings = {
        "application/mp4" => "video/mp4",
        "audio/mp3" => "audio/mpeg"
      }

      mappings.fetch(type, type)
    end
  end

  class FilenameStrategy < Struct.new(:filename)
    def lookup
      types = MIME::Types.type_for(filename)
      (types.first || ContentTypeDetection::Default).content_type
    end
  end

  class HybridStrategy < Struct.new(:filename, :filetype)
    def lookup
      types = MIME::Types.type_for(filename)

      type = if types.length == 1
        types.first
      elsif types.length > 1
        media_type = filetype.split('/').first
        types.detect {|t| t.media_type == media_type}
      end

      (type || ContentTypeDetection::Default).content_type
    end
  end
end
