# frozen_string_literal: true

module DeprecationToolkit
  class DeprecationAllowed
    class << self
      # Checks if a deprecation is allowed by the configured rules.
      #
      # A rule can be a `Regexp` to match the deprecation message, or a callable object that will receive the
      # message and the callstack to perform a more advanced check.
      #
      # @param payload [Hash] The payload from the deprecation event.
      # @option payload [String] :message The deprecation message.
      # @option payload [Array<String>] :callstack The callstack for the deprecation.
      # @return [Boolean] `true` if the deprecation is allowed, `false` otherwise.
      def call(payload)
        Configuration.allowed_deprecations.any? do |rule|
          if rule.is_a?(Regexp)
            rule.match?(payload[:message])
          else
            rule.call(payload[:message], payload[:callstack])
          end
        end
      end
    end
  end
end
