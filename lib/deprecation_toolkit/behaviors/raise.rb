# frozen_string_literal: true

module DeprecationToolkit
  module Behaviors
    class Raise
      def self.trigger(_test, current_deprecations, recorded_deprecations)
        error_class = if current_deprecations.size > recorded_deprecations.size
          DeprecationIntroduced
        elsif current_deprecations.size < recorded_deprecations.size
          DeprecationRemoved
        else
          DeprecationMismatch
        end

        raise error_class.new(current_deprecations, recorded_deprecations)
      end
    end

    DeprecationException = Class.new(StandardError)

    class DeprecationIntroduced < DeprecationException
      def initialize(current_deprecations, recorded_deprecations)
        introduced_deprecations = current_deprecations - recorded_deprecations

        message = <<~EOM
          You have introduced new deprecations in the codebase. Fix or record them in order to discard this error.
          You can record deprecations by adding the `--record-deprecations` flag when running your tests.

          #{introduced_deprecations.join("\n")}
        EOM

        super(message)
      end
    end

    class DeprecationRemoved < DeprecationException
      def initialize(current_deprecations, recorded_deprecations)
        removed_deprecations = recorded_deprecations - current_deprecations

        message = <<~EOM
          You have removed deprecations from the codebase. Thanks for being an awesome person.
          The recorded deprecations needs to be updated to reflect your changes.
          You can re-record deprecations by adding the `--record-deprecations` flag when running your tests.

          #{removed_deprecations.join("\n")}
        EOM

        super(message)
      end
    end

    class DeprecationMismatch < DeprecationException
      def initialize(current_deprecations, recorded_deprecations)
        message = <<~EOM
          The recorded deprecations for this test doesn't match the one that got triggered.
          Fix or record the new deprecations to discard this error.

          You can re-record deprecations by adding the `--record-deprecations` flag when running your tests.

          ===== Expected
          #{recorded_deprecations.deprecations.join("\n")}
          ===== Actual
          #{current_deprecations.deprecations.join("\n")}
        EOM

        super(message)
      end
    end
  end
end
