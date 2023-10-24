# frozen_string_literal: true

require "test_helper"

module DeprecationToolkit
  module Behaviors
    class DisabledTest < ActiveSupport::TestCase
      setup do
        @previous_configuration = Configuration.behavior
        Configuration.behavior = Disabled
      end

      teardown do
        Configuration.behavior = @previous_configuration
      end

      test ".trigger noop any deprecations" do
        assert_nothing_raised do
          ActiveSupport::Deprecation.new.warn("Foo")
          ActiveSupport::Deprecation.new.warn("Bar")

          trigger_deprecation_toolkit_behavior
        end
      end
    end
  end
end
