# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "boxlet/version"

Gem::Specification.new do |spec|
  spec.name          = "boxlet"
  spec.version       = Boxlet::VERSION
  spec.authors       = ["Clayton Liggitt", "arktisklada"]
  spec.email         = ["mail@enorganik.com"]
  spec.description   = %q{A server for Boxlet, a DIY, self-hosted file storage system}
  spec.summary       = spec.description
  spec.homepage      = "http://github.com/arktisklada/boxlet"
  spec.license       = "MIT"

  # spec.files         = `git ls-files`.split($/)
  spec.files         = %w[config.yml LICENSE.txt README.md Rakefile boxlet.gemspec]
  spec.files         += Dir.glob('lib/**/*.rb')

  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.executables   = 'boxlet'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w[lib]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
