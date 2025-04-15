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

        def behavior=(behavior)
          @behavior = Array(behavior)
        end
      end

      class Deprecators < Array
        def initialize(number)
          super()
          number.times { self << Deprecator.new }
        end

        def behaviour=(value)
          each { |deprecator| deprecator.behaviour = value }
        end
      end

      def deprecators
        @deprecators ||= Deprecators.new(3)
      end
    end

    teardown do
      DeprecationToolkit::DeprecationSubscriber.detach_from(:rails)
    end

    test ".plugin_deprecation_toolkit_options when running test with the `-r` flag" do
      option_parser = OptionParser.new
      options = {}

      Minitest.plugin_deprecation_toolkit_options(option_parser, options)
      option_parser.parse!(["-r"])

      assert_equal true, options[:record_deprecations]
    end

    test ".setup_deprecation_toolkit set the behavior to `Record` when `record_deprecations` options is true" do
      previous_behavior = DeprecationToolkit::Configuration.behavior
      Minitest.setup_deprecation_toolkit(record_deprecations: true)

      assert_equal(DeprecationToolkit::Behaviors::Record, DeprecationToolkit::Configuration.behavior)
    ensure
      DeprecationToolkit::Configuration.behavior = previous_behavior
    end

    if ActiveSupport.gem_version < Gem::Version.new("7.1.0")
      test ".setup_deprecation_toolkit add `notify` behavior to the deprecations behavior list" do
        deprecators_before = Rails.application.method(:deprecators)
        Rails.application.singleton_class.undef_method(:deprecators)
        behavior = ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:notify]
        Minitest.setup_deprecation_toolkit({})

        assert_includes(ActiveSupport::Deprecation.behavior, behavior)
      ensure
        Rails.application.singleton_class.define_method(:deprecators, &deprecators_before)
      end
    end

    if ActiveSupport.gem_version >= Gem::Version.new("7.2.0")
      test ".setup_deprecation_toolkit doesn't try to set behavior on ActiveSupport::Deprecation if Rails isn't defined" do
        stub_const(Object, :Rails, Object.new) do
          assert_nothing_raised do
            Minitest.setup_deprecation_toolkit({})
          end
        end
      end
    end

    test ".setup_deprecation_toolkit add `notify` behavior to the deprecations behavior list with Rails.application.deprecators" do
      behavior = ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:notify]

      with_fake_application do
        Minitest.setup_deprecation_toolkit({})

        Rails.application.deprecators.each do |deprecator|
          assert_includes(deprecator.behavior, behavior)
        end
      end
    end

    test ".setup_deprecation_toolkit doesn't remove previous deprecation behaviors" do
      behavior = ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:silence]
      with_fake_application do
        deprecator = Rails.application.deprecators.first
        deprecator.behavior = behavior

        Minitest.setup_deprecation_toolkit({})

        assert_includes deprecator.behavior, behavior
      end
    end

    test ".setup_deprecation_toolkit doesn't reattach subscriber when called multiple times" do
      deprecator = ActiveSupport::Deprecation.new("1.0", "my_gem")
      deprecator.behavior = :notify
      DeprecationToolkit::DeprecationSubscriber.attach_to(:my_gem)

      Minitest.setup_deprecation_toolkit({})

      assert_raises(DeprecationToolkit::Behaviors::DeprecationIntroduced) do
        deprecator.warn("Deprecated!")
        trigger_deprecation_toolkit_behavior
      end

      error = assert_raises(DeprecationToolkit::Behaviors::DeprecationIntroduced) do
        fake_rails_deprecator = ActiveSupport::Deprecation.new("next version", "Rails")
        fake_rails_deprecator.behavior = :notify
        fake_rails_deprecator.warn("Deprecated!")
        trigger_deprecation_toolkit_behavior
      end

      assert_equal(1, error.message.scan("DEPRECATION WARNING: Deprecated!").count)
    ensure
      DeprecationToolkit::DeprecationSubscriber.detach_from(:my_gem)
    end

    test ".plugin_deprecation_toolkit_init doesn't init plugin when outside bundler context" do
      with_fake_application do
        notify_behavior = ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:notify]
        old_bundle_gemfile = ENV["BUNDLE_GEMFILE"]
        ENV.delete("BUNDLE_GEMFILE")

        deprecator = Rails.application.deprecators.first
        deprecator.behavior.delete(notify_behavior)

        Minitest.plugin_deprecation_toolkit_init({})

        refute_includes(deprecator.behavior, notify_behavior)
      ensure
        ENV["BUNDLE_GEMFILE"] = old_bundle_gemfile
        deprecator.behavior << notify_behavior
      end
    end

    private

    def with_fake_application
      application_before = Rails.method(:application)
      Rails.singleton_class.redefine_method(:application) { @application ||= FakeApplication.new }
      yield
    ensure
      Rails.singleton_class.redefine_method(:application, &application_before)
    end
  end
end
