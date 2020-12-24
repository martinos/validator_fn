require "validator_fn/version"
require "fn_reader"

module ValidatorFn
  class Error < StandardError; end

  fn_reader :something, :matches, :either, :array_of, :any, :is_nil,
    :maybe, :present, :is_a, :int, :hash_of, :invalid, :generate_validator, :handle_error, :error_str

  class Error < StandardError; end

  @@invalid = ->msg { raise Error.new(msg) }
  @@something = ->a { invalid.("Cannot be nil") if a.nil?; a }
  @@matches = ->regex, a { invalid.("Should match") unless a =~ regex }.curry
  @@either = ->a, b, value {
    begin
      a.(value) || a.(value)
    rescue Error => e
    end
    a
  }.curry
  @@array_of = ->fn, array {
    is_a.(Array).(array)
    array.each_with_index do |a, idx|
      fn.(a)
    rescue Error => e
      invalid.("Invalid value in Array at index #{idx}")
    end
    array
  }.curry
  @@any = ->a { a }
  @@is_nil = ->a { invalid.("Should be nil") unless a.nil?; a }
  @@maybe = either.(is_nil)
  @@is_a = ->klass, a { invalid.("Expected type #{klass}, got #{a.inspect}") unless a.is_a?(klass); a }.curry
  @@int = ->a { invalid.("#{a.inspect} is not a valid integer") unless a.is_a?(Integer) }
  @@hash_of = ->fields, hash {
    hash ||= {}
    fields.map do |(key, fn)|
      [key, fn.(hash[key])]
    rescue Error => e
      invalid.("Invalid value for #{key.inspect} key.")
    end.to_h
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
        %{"#{k}" => #{generate_validator.(v)}}
      end.join(",\n  ")
      "hash_of.({ #{inner} })"
    when Array
      "array_of.( #{generate_validator.(a.first)} )"
    else
      "is_a.(#{a.class})"
    end
  }
end
