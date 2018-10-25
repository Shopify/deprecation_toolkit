# frozen_string_literal: true

require "test_helper"

module DeprecationToolkit
  class InitializationTest < ActiveSupport::TestCase
    test "calling .initialize again will not attach another subscriber" do
      assert_equal 1, DeprecationToolkit::DeprecationSubscriber.subscribers.count

      DeprecationToolkit.initialize

      assert_equal 1, DeprecationToolkit::DeprecationSubscriber.subscribers.count
    end
  end
end
