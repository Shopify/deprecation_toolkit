# frozen_string_literal: true

module DeprecationToolkit
  module Behaviors
    class Record
      extend ReadWriteHelper

      def self.trigger(test, collector, _)
        deprecation_file = recorded_deprecations_path(test)

        write(deprecation_file, test.name => collector.deprecations_without_stacktrace)
      end
    end
  end
end
