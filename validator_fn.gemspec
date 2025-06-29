require_relative 'lib/validator_fn/version'

Gem::Specification.new do |spec|
  spec.name          = "validator_fn"
  spec.version       = ValidatorFn::VERSION
  spec.authors       = ["Martin Chabot"]
  spec.email         = ["chabotm@gmail.com"]

  spec.summary       = %q{Series of lambdas for validating Ruby structures}
  spec.description   = %q{Series of lambdas for validating Ruby structures}
  spec.homepage      = "https://github.com/martinos/validator_fn"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")


  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/martinos/validator_fn"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) || f.match(%r{\.gem$}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "fn_reader"
end
