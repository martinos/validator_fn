# ValidatorFn

ValidatorFn is a collection of very simple lambdas that can be used for validating/transforming 
data structures.  It makes use of currying in order to provide a very composable 
DSL. To help you understand the concepts it is stongly advised to read [this blog post.](http://blog.martinosis.com/blog/simple-functional-strong-params-in-ruby/). 


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'validator_fn'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install validator_fn

## Usage

```
require 'validator_fn'
include ValidatorFn
```

You can start validating type of an object. 

```
is_a.(String).(3)
```

Note that parameters are curried. The first param of `is_a` is a Ruby class.
This will raise an ValidatorFn::Error

However if you send a valid entry as the second parametee, it will return that last parameter.

```
is_a.(String).("Joe")
# => "Joe"
```

This allows chaining lambdas:

```
to_int = is_a.(String) >> -> a { Integer(a) }

to_int.("12")
# => 12
to_int.("asdf") # will raise an exception
```

You can validate a hash:

```
user = hash_of.({name: is_a.(String), age: is_a.(Integer)})
user.({name: "", age: "234"})
```

Since we are using curried lambdas, you can compose validators as you which. 

```
postal_code = -> a { 
  invalid.("Invalid postal code: #{a}")  unless a =~ /[a-z]\d[a-z]\s*\d[a-z]\d/i
  a
}
contact =  hash_of.(user: user, 
                    address: hash_of.({ street_number: is_a.(Integer), 
                                        postal_code: postal_code}))
```

This is a very simple library (100 lines of code) that can be extended as you which by
creating your own lambdas.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/validator_fn. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/validator_fn/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ValidatorFn project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/validator_fn/blob/master/CODE_OF_CONDUCT.md).
Everyone interacting in the ValidatorFn project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/validator_fn/blob/master/CODE_OF_CONDUCT.md).
Everyone interacting in the ValidatorFn project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/validator_fn/blob/master/CODE_OF_CONDUCT.md).
Everyone interacting in the ValidatorFn project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/validator_fn/blob/master/CODE_OF_CONDUCT.md).
