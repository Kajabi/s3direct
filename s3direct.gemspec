# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 's3direct/version'

Gem::Specification.new do |spec|
  spec.name          = "s3direct"
  spec.version       = S3direct::VERSION
  spec.authors       = ["Brent Dillingham"]
  spec.email         = ["brentdillingham@gmail.com"]
  spec.description   = %q{Upload directly to S3}
  spec.summary       = %q{Upload directly to S3}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport', '>= 3.2.0'
  spec.add_dependency 'coffee-rails', '~> 3.2.1'
  spec.add_dependency 'jquery-fileupload-rails', '~> 0.4.1'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
