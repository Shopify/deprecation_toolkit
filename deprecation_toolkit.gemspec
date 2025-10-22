# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "deprecation_toolkit/version"

Gem::Specification.new do |spec|
  spec.name = "deprecation_toolkit"
  spec.version = DeprecationToolkit::VERSION
  spec.authors = ["Shopify"]
  spec.email = ["rails@shopify.com"]

  spec.summary = "Deprecation Toolkit around ActiveSupport::Deprecation"
  spec.homepage = "https://github.com/shopify/deprecation_toolkit"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Shopify/deprecation_toolkit/tree/v#{spec.version}"
  spec.metadata["changelog_uri"] = "https://github.com/Shopify/deprecation_toolkit/blob/main/CHANGELOG.md"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.required_ruby_version = ">= 3.2.0"

  spec.files = Dir["lib/**/*", "LICENSE.txt", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("activesupport", ">= 6.1")
end
