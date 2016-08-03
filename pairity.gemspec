# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pairity/version'

Gem::Specification.new do |spec|
  spec.name          = "viking-pairity"
  spec.version       = Pairity::VERSION
  spec.authors       = ["Kit Langton"]
  spec.email         = ["kitlangton@gmail.com"]

  spec.summary       = %q{A fair and balanced gem for pair rotation.}
  spec.description   = %q{A fair and balanced gem for pair rotation.}
  spec.homepage      = "https://github.com/kitlangton/pairity"
  spec.license       = "MIT"
  spec.required_ruby_version = '>= 2.1.0'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "pry-byebug"

  spec.add_dependency "highline", "~> 1.7.8"
  spec.add_dependency "rainbow", "~> 2.1"
  spec.add_dependency "google_drive", "~> 2.0"
  spec.add_dependency "terminal-table", "~> 1.6"
  spec.add_dependency "ruby-progressbar", "~> 1.8.1"
  spec.add_dependency "slack-poster", "~> 2.2.0"
  spec.add_dependency "graph_matching", "~> 0.0.1"
end
