# frozen_string_literal: true

require "test_helper"

class ConfigurationTest < ActiveSupport::TestCase
  attr_accessor :config_under_test, :config_value

  test "no exceptions is raised when new deprecations are introduced and behavior is set to Disabled" do
    @config_under_test = :behavior
    @config_value = DeprecationToolkit::Behaviors::Disabled

    assert_nothing_raised do
      ActiveSupport::Deprecation.warn("First deprecation")
    end
  end

  test "deprecation_path can be passed as a string" do
    @config_under_test = :deprecation_path
    @config_value = "test/deprecations/subfolder"

    assert_nothing_raised do
      ActiveSupport::Deprecation.warn("First deprecation")
    end
  end

  test "deprecation_path can be passed as a proc" do
    @config_under_test = :deprecation_path
    @config_value = ->(test_location) do
      "test/deprecations"
    end

    assert_nothing_raised do
      ActiveSupport::Deprecation.warn("First deprecation")
    end
  end

  def after_teardown
    old_value = DeprecationToolkit::Configuration.send(config_under_test)
    DeprecationToolkit::Configuration.send("#{config_under_test}=", @config_value)
    super
  ensure
    DeprecationToolkit::Configuration.send("#{config_under_test}=", old_value)
  end
end
