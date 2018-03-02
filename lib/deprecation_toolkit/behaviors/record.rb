# frozen_string_literal: true

module DeprecationToolkit
  module Behaviors
    class Record
      extend ReadWriteHelper

      def self.trigger(test, collector, _)
        write(test, collector.deprecations_without_stacktrace)
      end
    end
  end
end
