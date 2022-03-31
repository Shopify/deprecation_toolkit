# frozen_string_literal: true

require "active_support/configurable"

module DeprecationToolkit
  class Configuration
    include ActiveSupport::Configurable

    config_accessor(:allowed_deprecations) { [] }
    config_accessor(:attach_to) { [:rails] }
    config_accessor(:behavior) { Behaviors::Raise }
    config_accessor(:deprecation_path) { "test/deprecations" }
    config_accessor(:test_runner) { :minitest }
    config_accessor(:warnings_treated_as_deprecation) { [] }

    config_accessor(:message_normalizers) do
      normalizers = []

      normalizers << PathPrefixNormalizer.new(Rails.root) if defined?(Rails)
      normalizers << PathPrefixNormalizer.new(Bundler.root) if defined?(Bundler)

      if defined?(Gem)
        Gem.loaded_specs.each_value do |spec|
          normalizers << PathPrefixNormalizer.new(spec.bin_dir, replacement: "<GEM_BIN_DIR:#{spec.name}>")
          normalizers << PathPrefixNormalizer.new(spec.extension_dir, replacement: "<GEM_EXTENSION_DIR:#{spec.name}>")
          normalizers << PathPrefixNormalizer.new(spec.gem_dir, replacement: "<GEM_DIR:#{spec.name}>")
        end
        normalizers << PathPrefixNormalizer.new(*Gem.path, replacement: "<GEM_PATH>")
      end

      begin
        require "rbconfig"
        normalizers << PathPrefixNormalizer.new(
          *RbConfig::CONFIG.values_at("prefix", "sitelibdir", "rubylibdir"),
          replacement: "<RUBY_INTERNALS>",
        )
      rescue LoadError
        # skip normalizing ruby internal paths
      end

      normalizers << PathPrefixNormalizer.new(Dir.pwd)

      normalizers
    end
  end
end
