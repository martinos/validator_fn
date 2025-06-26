require "validator_fn/version"
require "validator_fn/error"
require "fn_reader"

module ValidatorFn
  fn_reader :something, :matches, :either, :array_of, :any, :is_nil,
    :maybe, :present, :is_a, :is_a_bool, :int, :hash_of, :invalid, :generate_validator, :handle_error, :error_str, :apply, :enum_of

  @@apply = ->fn, a {
    begin
      fn.(a)
    rescue StandardError => e
      invalid.("Error applying function")
    end
  }.curry
  @@invalid = ->msg { raise Error.new(msg) }
  @@something = ->a { invalid.("Cannot be nil") if a.nil?; a }
  @@matches = ->regex, a { invalid.("Should match") unless a =~ regex }.curry
  @@either = ->a, b, value {
    begin
      a.(value)
    rescue Error => e
      b.(value)
    end
    value
  }.curry
  @@enum_of = ->enum, a {
    raise Error.new("Should be in #{enum.join(",")}") unless enum.include?(a)
    a
  }.curry
  @@array_of = ->fn, array {
    is_a.(Array).(array)
    array.each_with_index.map do |a, idx|
      fn.(a)
    rescue Error => e
      invalid.("Invalid value in Array at index #{idx}")
    end
  }.curry
  @@any = ->a { a }
  @@is_nil = ->a { invalid.("Should be nil but was #{a}") unless a.nil?; a }
  @@maybe = either.(is_nil)
  @@is_a = ->klass, a { invalid.("Expected type #{klass}, got #{a.inspect}") unless a.is_a?(klass); a }.curry
  @@is_a_bool = ->a { invalid.("Expected bool, got #{a.inspect}") unless a == true || a == false; a }.curry
  # it validates each fields according with a specific algorithm, note that it
  # will filter out fields that are not defined
  @@hash_of = ->fields, hash {
    hash ||= {}
    fields.reduce({}) do |memo, (key, fn)|
      value = hash.fetch(key) { raise MissingKey.new(key) }
      memo[key] = fn.(value)
      memo
    rescue Error => e
      invalid.("Invalid value for #{key.inspect} key:")
    rescue MissingKey => e
      invalid.(e.message)
    end
  }.curry

  @@handle_error = ->on_error, validator, value {
    begin
      validator.(value)
    rescue Error => e
      on_error.(e)
    end
  }.curry
  @@error_str = ->idx, e {
    if !e.nil?
      indent = "  " * (idx + 1)
      "#{e.message}\n" + indent + error_str.(idx + 1).(e.cause)
    else
      ""
    end
  }.curry

  # Generating validator code from structure
  @@generate_validator = ->a {
    case a
    when nil
      "any"
    when Hash
      inner = a.map do |k, v|
        %{#{k.inspect} => #{generate_validator.(v)}}
      end.join(",\n  ")
      "hash_of.({ #{inner} })"
    when Array
      "array_of.( #{generate_validator.(a.first)} )"
    when TrueClass
      "is_a_bool"
    when FalseClass
      "is_a_bool"
    else
      "is_a.(#{a.class})"
    end
  }
end
