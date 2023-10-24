# frozen_string_literal: true

require "test_helper"
require "optparse"

module Minitest
  class DeprecationToolkitPluginTest < ActiveSupport::TestCase
    class FakeApplication
      class Deprecator
        def behavior
          @behavior ||= []
        end

        attr_writer :behavior
      end

      class Deprecatiors < Array
        def initialize(number)
          super()
          number.times { self << Deprecator.new }
        end

        def behaviour=(value)
          each { |deprecator| deprecator.behaviour = value }
        end
      end

      def deprecators
        @deprecators ||= Deprecatiors.new(3)
      end
    end

    test ".plugin_deprecation_toolkit_options when running test with the `-r` flag" do
      option_parser = OptionParser.new
      options = {}

      Minitest.plugin_deprecation_toolkit_options(option_parser, options)
      option_parser.parse!(["-r"])

      assert_equal true, options[:record_deprecations]
    end

    test ".plugin_deprecation_toolkit_init set the behavior to `Record` when `record_deprecations` options is true" do
      previous_behavior = DeprecationToolkit::Configuration.behavior
      Minitest.plugin_deprecation_toolkit_init(record_deprecations: true)

      assert_equal(DeprecationToolkit::Behaviors::Record, DeprecationToolkit::Configuration.behavior)
    ensure
      DeprecationToolkit::Configuration.behavior = previous_behavior
    end

    test ".plugin_deprecation_toolkit_init add `notify` behavior to the deprecations behavior list" do
      behavior = ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:notify]

      assert_includes ActiveSupport::Deprecation.behavior, behavior
    end

    test ".plugin_deprecation_toolkit_init add `notify` behavior to the deprecations behavior list with Rails.application.deprecators" do
      behavior = ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:notify]

      Rails.singleton_class.define_method(:application) { @application ||= FakeApplication.new }

      Minitest.plugin_deprecation_toolkit_init({})

      Rails.application.deprecators.each do |deprecator|
        assert_includes(deprecator.behavior, behavior)
      end

    ensure
      Rails.singleton_class.undef_method(:application)
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
        ActiveSupport::Deprecation.new.warn("Deprecated!")
        trigger_deprecation_toolkit_behavior
      end

      assert_equal 1, error.message.scan("DEPRECATION WARNING: Deprecated!").count
    end

    test ".plugin_deprecation_toolkit_init doesn't init plugin when outside bundler context" do
      notify_behavior = ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:notify]
      old_bundle_gemfile = ENV["BUNDLE_GEMFILE"]
      ENV.delete("BUNDLE_GEMFILE")

      ActiveSupport::Deprecation.behavior.delete(notify_behavior)
      Minitest.plugin_deprecation_toolkit_init({})

      refute_includes(ActiveSupport::Deprecation.behavior, notify_behavior)
    ensure
      ENV["BUNDLE_GEMFILE"] = old_bundle_gemfile
      ActiveSupport::Deprecation.behavior << notify_behavior
    end
  end
end
