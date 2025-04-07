# frozen_string_literal: true

require "test_helper"

module DeprecationToolkit
  class DeprecationToolkitTest < ActiveSupport::TestCase
    setup do
      @previous_attach_to = Configuration.attach_to
      @previous_behavior = Configuration.behavior
      Configuration.behavior = Behaviors::Disabled
    end

    teardown do
      Configuration.attach_to = @previous_attach_to
      Configuration.behavior = @previous_behavior
      # Clean up any subscribers that might have been attached during tests
      DeprecationSubscriber.detach_from(:test_gem)
      DeprecationSubscriber.detach_from(:another_gem)
      Collector.reset!
    end

    test ".attach_subscriber attaches to each gem specified in Configuration.attach_to" do
      Configuration.attach_to = [:test_gem]

      DeprecationToolkit.attach_subscriber

      test_deprecator = ActiveSupport::Deprecation.new("next version", "test_gem")
      test_deprecator.behavior = :notify

      test_deprecator.warn("Test deprecation message")

      assert_equal 1, Collector.deprecations.size
      assert_match(/^DEPRECATION WARNING: Test deprecation message/, Collector.deprecations.first)
    end

    test ".attach_subscriber does nothing when Configuration.attach_to is empty" do
      Configuration.attach_to = []

      DeprecationToolkit.attach_subscriber

      test_deprecator = ActiveSupport::Deprecation.new("next version", "test_gem")
      test_deprecator.behavior = :notify

      test_deprecator.warn("Test deprecation message")

      assert_equal 0, Collector.deprecations.size
    end

    test ".attach_subscriber adds new gems without duplicating existing subscribers" do
      Configuration.attach_to = [:test_gem]
      DeprecationToolkit.attach_subscriber

      test_deprecator = ActiveSupport::Deprecation.new("next version", "test_gem")
      test_deprecator.behavior = :notify

      test_deprecator.warn("Test deprecation message 1")

      assert_equal 1, Collector.deprecations.size

      Configuration.attach_to = [:test_gem, :another_gem]

      DeprecationToolkit.attach_subscriber

      Collector.reset!

      another_deprecator = ActiveSupport::Deprecation.new("next version", "another_gem")
      another_deprecator.behavior = :notify

      another_deprecator.warn("Test deprecation message 2")

      assert_equal 1, Collector.deprecations.size
      assert_match(/^DEPRECATION WARNING: Test deprecation message 2/, Collector.deprecations.first)

      Collector.reset!
      test_deprecator.warn("Test deprecation message 3")
      assert_equal 1, Collector.deprecations.size
      assert_match(/^DEPRECATION WARNING: Test deprecation message 3/, Collector.deprecations.first)
    end
  end
end
