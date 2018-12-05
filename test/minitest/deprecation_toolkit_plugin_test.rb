# frozen_string_literal: true

require "test_helper"
require "optparse"

module Minitest
  class DeprecationToolkitPluginTest < ActiveSupport::TestCase
    test ".plugin_deprecation_toolkit_options when running test with the `-r` flag" do
      option_parser = OptionParser.new
      options = {}

      Minitest.plugin_deprecation_toolkit_options(option_parser, options)
      option_parser.parse!(["-r"])

      assert_equal true, options[:record_deprecations]
    end

    test ".plugin_deprecation_toolkit_init set the behavior to `Record` when `record_deprecations` options is true" do
      begin
        previous_behavior = DeprecationToolkit::Configuration.behavior
        Minitest.plugin_deprecation_toolkit_init(record_deprecations: true)

        assert_equal(DeprecationToolkit::Behaviors::Record, DeprecationToolkit::Configuration.behavior)
      ensure
        DeprecationToolkit::Configuration.behavior = previous_behavior
      end
    end

    test ".plugin_deprecation_toolkit_init add `notify` behavior to the deprecations behavior list" do
      behavior = ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:notify]

      assert_includes ActiveSupport::Deprecation.behavior, behavior
    end

    test ".plugin_deprecation_toolkit_init doesn't remove previous deprecation behaviors" do
      behavior = ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:silence]
      ActiveSupport::Deprecation.behavior = behavior

      Minitest.plugin_deprecation_toolkit_init({})

      assert_includes ActiveSupport::Deprecation.behavior, behavior
    end

    test ".plugin_deprecation_toolkit_init doesn't reattach subscriber when called multiple times" do
      deprecator = ActiveSupport::Deprecation.new("1.0", "my_gem")
      deprecator.behavior = :notify
      DeprecationToolkit::DeprecationSubscriber.attach_to(:my_gem)

      Minitest.plugin_deprecation_toolkit_init({})

      assert_raises(DeprecationToolkit::Behaviors::DeprecationIntroduced) do
        deprecator.warn("Deprecated!")
        trigger_deprecation_toolkit_behavior
      end

      error = assert_raises(DeprecationToolkit::Behaviors::DeprecationIntroduced) do
        ActiveSupport::Deprecation.warn("Deprecated!")
        trigger_deprecation_toolkit_behavior
      end

      assert_equal 1, error.message.scan("DEPRECATION WARNING: Deprecated!").count
    end
  end
end
