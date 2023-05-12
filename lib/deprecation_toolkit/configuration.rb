# frozen_string_literal: true

require "active_support/configurable"

module DeprecationToolkit
  class Configuration
    include ActiveSupport::Configurable

    PREVIOUS_WARNING_DEPRECATED_CATEGORY = ::Warning[:deprecated]

    config_accessor(:allowed_deprecations) { [] }
    config_accessor(:attach_to) { [:rails] }
    config_accessor(:behavior) { Behaviors::Raise }
    config_accessor(:deprecation_path) { "test/deprecations" }
    config_accessor(:test_runner) { :minitest }
    config_accessor(:warnings_treated_as_deprecation) { [] }
    config_accessor(:warning_deprecated_category)

    def self.warning_deprecated_category=(value)
      ::Warning[:deprecated] =
        if value.nil?
          PREVIOUS_WARNING_DEPRECATED_CATEGORY
        else
          value
        end
      config.warning_deprecated_category = value
    end

    self.warning_deprecated_category = true
  end
end
