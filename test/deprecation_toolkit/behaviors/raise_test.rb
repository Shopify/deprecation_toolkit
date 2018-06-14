# frozen_string_literal: true

require "test_helper"

module DeprecationToolkit
  module Behaviors
    class RaiseTest < ActiveSupport::TestCase
      setup do
        @previous_configuration = Configuration.behavior
        Configuration.behavior = Raise
      end

      teardown do
        Configuration.behavior = @previous_configuration
      end

      test ".trigger raises an DeprecationIntroduced error when deprecations are introduced" do
        @expected_exception = DeprecationIntroduced

        ActiveSupport::Deprecation.warn("Foo")
        ActiveSupport::Deprecation.warn("Bar")
      end

      test ".trigger raises a DeprecationRemoved error when deprecations are removed" do
        @expected_exception = DeprecationRemoved

        ActiveSupport::Deprecation.warn("Foo")
      end

      test ".trigger does not raise when deprecations are triggered but were already recorded" do
        assert_nothing_raised do
          ActiveSupport::Deprecation.warn("Foo")
          ActiveSupport::Deprecation.warn("Bar")
        end
      end

      test ".trigger does not raise when deprecations are allowed" do
        @old_allowed_deprecations = Configuration.allowed_deprecations
        Configuration.allowed_deprecations = [/John Doe/]

        begin
          ActiveSupport::Deprecation.warn("John Doe")
          assert_nothing_raised { trigger_deprecation_toolkit_behavior }
        ensure
          Configuration.allowed_deprecations = @old_allowed_deprecations
        end
      end

      def trigger_deprecation_toolkit_behavior
        super
      rescue DeprecationIntroduced, DeprecationRemoved => e
        assert_equal @expected_exception, e.class
      end
    end
  end
end
