# frozen_string_literal: true

require "test_helper"

module DeprecationToolkit
  class ConfigurationTest < ActiveSupport::TestCase
    test ".behavior is by default set to Raise" do
      assert_equal Behaviors::Raise, Configuration.behavior
    end

    test ".allowed_deprecations is by default empty" do
      assert_empty Configuration.allowed_deprecations
    end

    test ".deprecation_path is by default set to `test/deprecations`" do
      assert_equal "test/deprecations", Configuration.deprecation_path
    end

    test ".attach_to is by default set to `rails`" do
      assert_equal [:rails], Configuration.attach_to
    end

    test ".test_runner is by default set to `minitest`" do
      assert_equal :minitest, Configuration.test_runner
    end

    test ".configure allows setting configuration options" do
      previous_behavior = Configuration.behavior

      Configuration.configure do |config|
        config.behavior = Behaviors::Disabled
      end

      assert_equal(Behaviors::Disabled, Configuration.behavior)
    ensure
      Configuration.behavior = previous_behavior
    end

    test ".config can be used to configure" do
      previous_behavior = Configuration.behavior

      DeprecationToolkit::Configuration.config.behavior = Behaviors::Disabled

      assert_equal(Behaviors::Disabled, Configuration.behavior)
    ensure
      Configuration.behavior = previous_behavior
    end
  end
end
