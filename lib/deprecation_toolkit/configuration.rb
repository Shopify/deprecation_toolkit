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
    config_accessor(:project_root) { '~/dev/freeagent' }
    config_accessor(:gem_home) { '/home/ubuntu/.gems/ruby/2.7.1' }
  end
end
