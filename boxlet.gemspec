# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "boxlet/version"

Gem::Specification.new do |spec|
  spec.name          = "boxlet"
  spec.version       = Boxlet::VERSION
  spec.authors       = ["arktisklada"]
  spec.email         = ["mail@enorganik.com"]
  spec.summary       = %q{Upload pics from your phone}
  spec.description   = spec.summary
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = %w[config.yml LICENSE.txt README.md Rakefile boxlet.gemspec]
  spec.files         += Dir.glob('lib/**/*.rb')
  spec.files         += Dir.glob('lib/boxlet/app/*.rb')

  spec.executables   = 'boxlet'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rack", "~> 1.5"
  spec.add_dependency "rack-contrib", "~> 1.1"
  spec.add_dependency "thin", "~> 1.6"
  spec.add_dependency "multi_json", "~> 1.10.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
