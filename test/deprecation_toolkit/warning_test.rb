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
  end
end
