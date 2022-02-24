# ValidatorFn

ValidatorFn is a collection of very simple lambdas that can be used for validating/transforming
data structures. It makes use of currying to provide a very composable
DSL. To help you understand the concepts, I strongly advise reading [this blog post.](http://blog.martinosis.com/blog/simple-functional-strong-params-in-ruby/).

It can be very useful for validating structures that come from input, such as configuration files, JSON APIs, test results.

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

```ruby
require 'validator_fn'
include ValidatorFn
```

You can start validating the type of an object.

```ruby
is_a.(String).(3)
```

Note that parameters are curried. The first param of `is_a` is the Ruby class you want to check the last parameter against.
In the previous example, a `ValidatorFn::Error`exception will be raised.

However, setting a valid entry as the second parameter will return that last parameter.

```ruby
is_a.(String).("Joe")
# => "Joe"
```

This allows chaining lambdas:

```ruby
to_int = is_a.(String) >> -> a { Integer(a) }

to_int.("12")
# => 12
to_int.("asdf") # will raise an exception
```

You can validate a hash:

```ruby
user = hash_of.({name: is_a.(String), age: to_int})
user.({name: "", age: "234"})
```

Since we are using curried lambdas, you can compose validators as you which.

```ruby
postal_code = -> a {
  invalid.("Invalid postal code: #{a}")  unless a =~ /[a-z]\d[a-z]\s*\d[a-z]\d/i
  a
}
contact =  hash_of.(user: user,
                    address: hash_of.({ street_number: is_a.(Integer),
                                        postal_code: postal_code}))
```

This very simple library (100 lines of code) can be extended easily by creating new lambdas.

## Casting

You can also apply converter functions to the structure.

```ruby
user = { name: "Joe", created_at: "2020-01-03" }
to_date = ->str { Date.parse(str) }
user_validator = hash_of.(name: is_a.(String),
                          created_at: is_a.(String) >> to_date)

user_validator.(user)
# => {:name=>"Joe", :created_at=>#<Date: 2020-01-03 ((2458852j,0s,0n),+0s,2299161j)>}
```

This makes it very useful for processing JSON payloads.

## Code generation

You can generate validator code from existing structure:

```ruby
require 'openuri'
require "json"
struct = JSON.parse(URI.open("https://api.github.com/users/defunkt").read)

require "validator_fn"

# Generate unformatted code
code = ValidatorFn.generate_validator.(struct)

# You can reformat it using a code formatter
require "rufo"
puts Rufo.format(code)
hash_of.({ "login" => is_a.(String),
           "id" => is_a.(Integer),
           "node_id" => is_a.(String),
           "avatar_url" => is_a.(String),
           "gravatar_id" => is_a.(String),
           "url" => is_a.(String),
           "html_url" => is_a.(String),
           "followers_url" => is_a.(String),
           "following_url" => is_a.(String),
           "gists_url" => is_a.(String),
           "starred_url" => is_a.(String),
           "subscriptions_url" => is_a.(String),
           "organizations_url" => is_a.(String),
           "repos_url" => is_a.(String),
           "events_url" => is_a.(String),
           "received_events_url" => is_a.(String),
           "type" => is_a.(String),
           "site_admin" => is_a_bool,
           "name" => is_a.(String),
           "company" => any,
           "blog" => is_a.(String),
           "location" => any,
           "email" => any,
           "hireable" => any,
           "bio" => is_a.(String),
           "twitter_username" => any,
           "public_repos" => is_a.(Integer),
           "public_gists" => is_a.(Integer),
           "followers" => is_a.(Integer),
           "following" => is_a.(Integer),
           "created_at" => is_a.(String),
           "updated_at" => is_a.(String) })
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/validator_fn. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/validator_fn/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ValidatorFn project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/validator_fn/blob/master/CODE_OF_CONDUCT.md).

git push test
