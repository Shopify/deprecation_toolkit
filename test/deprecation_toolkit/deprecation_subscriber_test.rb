# frozen_string_literal: true

require "test_helper"

module DeprecationToolkit
  class DeprecationSubscriberTest < ActiveSupport::TestCase
    setup do
      @previous_behavior = Configuration.behavior
      @previous_allowed_deprecations = Configuration.allowed_deprecations
      Configuration.behavior = Behaviors::Disabled
      Configuration.allowed_deprecations = []
      Collector.reset!
    end

    teardown do
      Configuration.behavior = @previous_behavior
      Configuration.allowed_deprecations = @previous_allowed_deprecations
      DeprecationSubscriber.detach_from(:test_gem)
      Collector.reset!
    end

    test ".attach_to attaches a subscriber to a gem" do
      test_deprecator = ActiveSupport::Deprecation.new("next version", "test_gem")
      test_deprecator.behavior = :notify

      DeprecationSubscriber.attach_to(:test_gem)

      test_deprecator.warn("Test deprecation message")

      assert_equal 1, Collector.deprecations.size
      assert_match(/^DEPRECATION WARNING: Test deprecation message/, Collector.deprecations.first)
    end

    test ".attach_to does not attach a subscriber if already attached" do
      test_deprecator = ActiveSupport::Deprecation.new("next version", "test_gem")
      test_deprecator.behavior = :notify

      DeprecationSubscriber.attach_to(:test_gem)
      DeprecationSubscriber.attach_to(:test_gem)

      test_deprecator.warn("Test deprecation message")

      assert_equal 1, Collector.deprecations.size
    end

    test ".detach_from removes a subscriber" do
      test_deprecator = ActiveSupport::Deprecation.new("next version", "test_gem")
      test_deprecator.behavior = :notify

      DeprecationSubscriber.attach_to(:test_gem)

      DeprecationSubscriber.detach_from(:test_gem)

      test_deprecator.warn("Test deprecation message")

      assert_equal 0, Collector.deprecations.size
    end

    test "#deprecation does not collect allowed deprecations" do
      Configuration.allowed_deprecations = [/Test deprecation message/]

      test_deprecator = ActiveSupport::Deprecation.new("next version", "test_gem")
      test_deprecator.behavior = :notify

      DeprecationSubscriber.attach_to(:test_gem)

      test_deprecator.warn("Test deprecation message")

      assert_equal 0, Collector.deprecations.size
    end

    test "#deprecation does not collect deprecations allowed by a proc" do
      Configuration.allowed_deprecations = [
        ->(message, _stack) { message.include?("Test deprecation message") },
      ]

      test_deprecator = ActiveSupport::Deprecation.new("next version", "test_gem")
      test_deprecator.behavior = :notify

      DeprecationSubscriber.attach_to(:test_gem)

      test_deprecator.warn("Test deprecation message")

      assert_equal 0, Collector.deprecations.size
    end
  end
end
