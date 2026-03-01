# frozen_string_literal: true

require_relative "lib/flourish/version"

Gem::Specification.new do |spec|
  spec.name          = "flourish"
  spec.version       = Flourish::VERSION
  spec.authors       = ["Chamomile Contributors"]
  spec.summary       = "Terminal styling library for Ruby"
  spec.description   = "CSS-like box model styling for terminal output — colors, padding, margins, borders, alignment"
  spec.license       = "MIT"
  spec.require_paths = ["lib"]
  spec.files         = Dir["lib/**/*.rb"]
  spec.required_ruby_version = ">= 3.2.0"

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.metadata["rubygems_mfa_required"] = "true"
end
