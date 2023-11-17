# frozen_string_literal: true

require "test_helper"

module DeprecationToolkit
  module Behaviors
    class DisabledTest < ActiveSupport::TestCase
      include TestDeprecator

      setup do
        @previous_configuration = Configuration.behavior
        Configuration.behavior = Disabled
      end

      teardown do
        Configuration.behavior = @previous_configuration
      end

      test ".trigger noop any deprecations" do
        assert_nothing_raised do
          deprecator.warn("Foo")
          deprecator.warn("Bar")

          trigger_deprecation_toolkit_behavior
        end
      end
    end
  end
end
