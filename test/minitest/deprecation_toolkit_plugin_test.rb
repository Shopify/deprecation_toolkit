# frozen_string_literal: true

require "test_helper"

module Minitest
  class DeprecationToolkitPluginTest < ActiveSupport::TestCase
    test "plugin kicks in and add `notify` behavior to the deprecations behavior list" do
      behavior = ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:notify]

      assert_includes ActiveSupport::Deprecation.behavior, behavior
    end

    test "plugin kicks in add attach the DeprecationSubscriber to `rails` by default" do
      DeprecationToolkit::Configuration.behavior = DeprecationToolkit::Behaviors::Disabled
      ActiveSupport::Deprecation.warn("This is a deprecation")

      assert_equal 1, DeprecationToolkit::Collector.deprecations.count
    end
  end
end
