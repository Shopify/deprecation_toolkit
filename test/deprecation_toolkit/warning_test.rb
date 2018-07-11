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

    test 'treats warnings as deprecations' do
      Configuration.warnings_treated_as_deprecation = [/#example is deprecated/]

      assert_raises Behaviors::DeprecationIntroduced do
        warn '#example is deprecated'

        trigger_deprecation_toolkit_behavior
      end
    end

    test 'warn can be called with an array' do
      Configuration.warnings_treated_as_deprecation = [/#example is deprecated/, /#something is deprecated/]

      error = assert_raises Behaviors::DeprecationIntroduced do
        warn ['#example is deprecated', '#something is deprecated']

        trigger_deprecation_toolkit_behavior
      end

      assert_match(/DEPRECATION WARNING: #example is deprecated/, error.message)
      assert_match(/#something is deprecated/, error.message)
    end

    test 'warn can be called with multiple arguments' do
      Configuration.warnings_treated_as_deprecation = [/#example is deprecated/, /#something is deprecated/]

      error = assert_raises Behaviors::DeprecationIntroduced do
        warn '#example is deprecated', '#something is deprecated'

        trigger_deprecation_toolkit_behavior
      end

      assert_match(/DEPRECATION WARNING: #example is deprecated/, error.message)
      assert_match(/#something is deprecated/, error.message)
    end

    test 'warn works as usual when no warnings are treated as deprecation' do
      assert_nothing_raised do
        warn 'Test warn works correctly'
      end
    end
  end
end
