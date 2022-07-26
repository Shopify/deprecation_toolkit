# frozen_string_literal: true

require "test_helper"

module DeprecationToolkit
  class WarningTest < ActiveSupport::TestCase
    setup do
      @previous_warnings_treated_as_deprecation = Configuration.warnings_treated_as_deprecation
    end

    teardown do
      Configuration.warnings_treated_as_deprecation = @previous_warnings_treated_as_deprecation
    end

    test "treats warnings as deprecations" do
      Configuration.warnings_treated_as_deprecation = [/#example is deprecated/]

      assert_raises Behaviors::DeprecationIntroduced do
        warn "#example is deprecated"

        trigger_deprecation_toolkit_behavior
      end
    end

    test "Kernel.warn treats warnings as deprecations " do
      Configuration.warnings_treated_as_deprecation = [/#example is deprecated/]

      assert_raises Behaviors::DeprecationIntroduced do
        Kernel.warn("#example is deprecated")

        trigger_deprecation_toolkit_behavior
      end
    end

    test "warn can be called with an array" do
      Configuration.warnings_treated_as_deprecation = [/#example is deprecated/, /#something is deprecated/]

      error = assert_raises(Behaviors::DeprecationIntroduced) do
        warn(["#example is deprecated", "#something is deprecated"])

        trigger_deprecation_toolkit_behavior
      end

      assert_match(/DEPRECATION WARNING: #example is deprecated/, error.message)
      assert_match(/#something is deprecated/, error.message)
    end

    test "warn can be called with multiple arguments" do
      Configuration.warnings_treated_as_deprecation = [/#example is deprecated/, /#something is deprecated/]

      error = assert_raises(Behaviors::DeprecationIntroduced) do
        warn("#example is deprecated", "#something is deprecated")

        trigger_deprecation_toolkit_behavior
      end

      assert_match(/DEPRECATION WARNING: #example is deprecated/, error.message)
      assert_match(/#something is deprecated/, error.message)
    end

    test "warn works as usual when no warnings are treated as deprecation" do
      assert_nothing_raised do
        capture_io do
          warn "Test warn works correctly"
        end
      end
    end

    test "Ruby 2.7 two-part keyword argument warning are joined together" do
      Configuration.warnings_treated_as_deprecation = [/Using the last argument as keyword parameters/]

      error = assert_raises(Behaviors::DeprecationIntroduced) do
        warn("/path/to/caller.rb:1: warning: Using the last argument as keyword parameters is deprecated; " \
          "maybe ** should be added to the call")
        warn("/path/to/calleee.rb:1: warning: The called method `method_name' is defined here")

        trigger_deprecation_toolkit_behavior
      end

      assert_match(/Using the last argument as keyword parameters/, error.message)
      assert_match(/The called method/, error.message)
    end
  end
end
