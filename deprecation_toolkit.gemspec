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
  spec.metadata["source_code_uri"] = "https://github.com/shopify/deprecation_toolkit"
  spec.metadata["changelog_uri"] = "https://github.com/Shopify/deprecation_toolkit/blob/master/CHANGELOG.md"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.required_ruby_version = ">= 2.5"

  spec.files = %x(git ls-files -z).split("\x0").reject do |f|
    f.match(%r{^(test)/})
  end
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("activesupport", ">= 4.2")

  spec.add_development_dependency("bundler", ">= 1.16")
  spec.add_development_dependency("minitest", "~> 5.0")
  spec.add_development_dependency("rake", "~> 10.0")
  spec.add_development_dependency("rspec", "~> 3.0")
end
