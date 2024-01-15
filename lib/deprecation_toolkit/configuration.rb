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
    config_accessor(:deprecation_file_path_format) do
      proc do |test|
        if DeprecationToolkit::Configuration.test_runner == :rspec
          test.example_group.file_path.sub(%r{^./spec/}, "").sub(/_spec.rb$/, "")
        else
          test.class.name.underscore
        end
      end
    end
  end
end
