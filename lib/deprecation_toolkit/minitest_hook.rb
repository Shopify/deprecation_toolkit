# frozen_string_literal: true

require "minitest/test"

module DeprecationToolkit
  module Minitest
    def ensure_no_deprecation
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

class Minitest::Test
  include DeprecationToolkit::Minitest

  TEARDOWN_METHODS << "ensure_no_deprecation"
end
