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
  spec.homepage      = "https://github.com/arktisklada/boxlet"
  spec.license       = "MIT"

  spec.files         = %w[config.yml LICENSE.txt README.md Rakefile boxlet.gemspec]
  spec.files         += Dir.glob('lib/**/*.rb')
  spec.files         += Dir.glob('lib/boxlet/app/*.rb')

  spec.executables   = 'boxlet'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rack", "~> 1.5.2"
  spec.add_dependency "rack-contrib", "~> 1.1.0"
  spec.add_dependency "thin", "~> 1.6.4"
  spec.add_dependency "ImageResize", "~> 0.0.5"

  spec.add_runtime_dependency 'multi_json', '~> 1.10', '>= 1.10.1'
  spec.add_runtime_dependency 'mongo', '~> 1.10', '>= 1.10.2'
  spec.add_runtime_dependency 'bson_ext', '~> 1.10', '>= 1.10.2'
  spec.add_runtime_dependency 'sys-filesystem', '~> 1.1', '>= 1.1.2'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.3"
end
