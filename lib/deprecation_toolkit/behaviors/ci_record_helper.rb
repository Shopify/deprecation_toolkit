# frozen_string_literal: true

require "json"

module DeprecationToolkit
  module Behaviors
    module CIRecordHelper
      extend self
      extend ReadWriteHelper

      HEADER = "[DeprecationToolkit]"

      def trigger(test, current_deprecations, _recorded_deprecations)
        filename = recorded_deprecations_path(test)

        to_output = {
          filename.to_s => {
            test_name(test) => current_deprecations.deprecations_without_stacktrace,
          },
        }

        raise "#{HEADER} #{JSON.dump(to_output)}"
      end
    end
  end
end
