# frozen_string_literal: true

require_relative "lib/flourish/version"

Gem::Specification.new do |spec|
  spec.name          = "chamomile-flourish"
  spec.version       = Flourish::VERSION
  spec.authors       = ["Jack Killilea"]
  spec.summary       = "Terminal styling library for Ruby"
  spec.description   = "CSS-like box model styling for terminal output — colors, padding, margins, borders, alignment"
  spec.license       = "MIT"
  spec.require_paths = ["lib"]
  spec.files         = Dir["lib/**/*.rb"]
  spec.required_ruby_version = ">= 3.2.0"

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.homepage = "https://github.com/chamomile-rb/flourish"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["homepage_uri"]          = spec.homepage
  spec.metadata["source_code_uri"]       = "https://github.com/chamomile-rb/flourish"
  spec.metadata["changelog_uri"]         = "https://github.com/chamomile-rb/flourish/blob/master/CHANGELOG.md"
end
