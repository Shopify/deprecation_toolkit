# frozen_string_literal: true

module DeprecationToolkit
  module Behaviors
    module Record
      extend self
      extend ReadWriteHelper

      def trigger(test, collector, _)
        deprecation_file = recorded_deprecations_path(test)

        write(deprecation_file, test_name(test) => collector.deprecations_without_stacktrace)
      end
    end
  end
end
