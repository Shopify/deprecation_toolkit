# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "deprecation_toolkit/version"

Gem::Specification.new do |spec|
  spec.name = "deprecation_toolkit"
  spec.version = DeprecationToolkit::VERSION
  spec.authors = %w(Shopify)
  spec.email = ["rails@shopify.com"]

  spec.summary = "Deprecation Toolkit around ActiveSupport::Deprecation"
  spec.homepage = "https://github.com/shopify/deprecation_toolkit"
  spec.license = "MIT"

  spec.required_ruby_version = '>= 2.3'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test)/})
  end
  spec.require_paths = %w(lib)

  spec.add_runtime_dependency 'activesupport', '>= 5.0'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
