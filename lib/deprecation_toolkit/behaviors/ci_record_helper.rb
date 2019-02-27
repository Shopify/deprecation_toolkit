# frozen_string_literal: true

require 'json'

module DeprecationToolkit
  module Behaviors
    class CIRecordHelper
      extend ReadWriteHelper

      HEADER = '[DeprecationToolkit]'

      def self.trigger(test, current_deprecations, _recorded_deprecations)
        filename = recorded_deprecations_path(test)

        to_output = {
          filename.to_s => {
            test.name => current_deprecations.deprecations_without_stacktrace,
          },
        }

        raise "#{HEADER} #{JSON.dump(to_output)}"
      end
    end
  end
end
