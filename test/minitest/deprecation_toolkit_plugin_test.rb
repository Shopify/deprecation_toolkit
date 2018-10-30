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

        assert_equal DeprecationToolkit::Behaviors::Record, DeprecationToolkit::Configuration.behavior
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
  end
end
