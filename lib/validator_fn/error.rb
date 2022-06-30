module ValidatorFn
  class Error < StandardError
    attr_reader :my_msg

    def initialize(msg)
      @my_msg = msg
      super(msg)
    end

    def message(indent = 0)
      if cause
        cause_msg = if cause.kind_of?(Error)
            cause.message(indent + 1)
          else
            cause.message
          end
        my_msg + "\n" + ("  " * (indent + 1)) + cause_msg
      else
        my_msg
      end
    end
  end

  class MissingKey < Error
    def initialize(key)
      super("Missing field #{key}")
    end
  end
end
