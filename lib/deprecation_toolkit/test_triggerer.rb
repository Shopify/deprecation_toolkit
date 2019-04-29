# frozen_string_literal: true

module DeprecationToolkit
  module TestTriggerer
    def self.trigger_deprecation_toolkit_behavior(test)
      current_deprecations = DeprecationToolkit::Collector.new(DeprecationToolkit::Collector.deprecations)
      recorded_deprecations = DeprecationToolkit::Collector.load(test)
      if !recorded_deprecations.flaky? && current_deprecations != recorded_deprecations
        DeprecationToolkit::Configuration.behavior.trigger(
          test, current_deprecations, recorded_deprecations
        )
      end
    ensure
      DeprecationToolkit::Collector.reset!
    end
  end
end
