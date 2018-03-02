# frozen_string_literal: true

require "minitest/test"

module DeprecationToolkit
  module Minitest
    def after_teardown
      super

      current_deprecations = Collector.new(Collector.deprecations)
      recorded_deprecations = Collector.load(self)
      if current_deprecations != recorded_deprecations
        Configuration.behavior.trigger(self, current_deprecations, recorded_deprecations)
      end
    ensure
      Collector.reset!
    end
  end
end

Minitest::Test.include(DeprecationToolkit::Minitest)
