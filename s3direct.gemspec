# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 's3direct/version'

Gem::Specification.new do |spec|
  spec.name          = "s3direct"
  spec.version       = S3Direct::VERSION
  spec.authors       = ["Brent Dillingham"]
  spec.email         = ["brentdillingham@gmail.com"]
  spec.summary       = %q{Upload directly to S3}
  spec.description   = spec.summary
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport', '>= 3.2.0'
  spec.add_dependency 'jquery-fileupload-rails', '~> 0.4.1'
  spec.add_dependency 'coffee-rails'
  spec.add_dependency 'ejs'
  spec.add_dependency 'mime-types'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rails", ">= 3.2.1"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
