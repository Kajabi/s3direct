module S3Direct
  class StringInterpolator
    DELIM = "/"

    attr_reader :context, :pattern

    def initialize(context, pattern)
      @pattern = pattern
      @context = context
    end

    def to_s
      compile_parts.join(DELIM)
    end

    def compile_parts
      pattern.split(DELIM).collect do |part|
        if part[0] == ':'
          meth = part[1, part.length - 1]
          result = context.public_send meth
          if result.blank?
            raise ":#{meth} for path '#{pattern}' was blank in #{context.inspect}"
          end
          result.to_s.underscore
        else
          part
        end
      end
    end
  end
end
