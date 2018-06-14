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
  end
end
