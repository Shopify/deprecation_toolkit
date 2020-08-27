# frozen_string_literal: true

module DeprecationToolkit
  module Behaviors
    class Record
      extend ReadWriteHelper

      def self.trigger(test, collector, _)
        deprecation_file = recorded_deprecations_path(test)
        write(deprecation_file, test_name(test) => make_paths_relative(collector.deprecations_without_stacktrace))
      end

      def self.make_paths_relative(warnings)
        warnings.collect do |warning|
          warning.gsub(DeprecationToolkit::Configuration.project_root + '/', '')
        end
      end
    end
  end
end
