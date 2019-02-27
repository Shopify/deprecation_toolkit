# frozen_string_literal: true

require "minitest"

module DeprecationToolkit
  module Minitest
    def trigger_deprecation_toolkit_behavior
      current_deprecations = Collector.new(Collector.deprecations)
      recorded_deprecations = Collector.load(self)
      if !recorded_deprecations.flaky? && current_deprecations != recorded_deprecations
        Configuration.behavior.trigger(self, current_deprecations, recorded_deprecations)
      end
    ensure
      Collector.reset!
    end
  end
end

module Minitest
  class Test
    include DeprecationToolkit::Minitest

    TEARDOWN_METHODS << "trigger_deprecation_toolkit_behavior"
  end
end
