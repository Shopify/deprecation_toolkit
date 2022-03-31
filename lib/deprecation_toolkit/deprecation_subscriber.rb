# frozen_string_literal: true

require "active_support/subscriber"

module DeprecationToolkit
  class DeprecationSubscriber < ActiveSupport::Subscriber
    def self.already_attached?
      notifier != nil
    end

    def deprecation(event)
      message = normalize_message(event.payload[:message])

      Collector.collect(message) unless deprecation_allowed?(message, event.payload[:callstack])
    end

    private

    def deprecation_allowed?(message, callstack)
      allowed_deprecations, procs = Configuration.allowed_deprecations.partition { |el| el.is_a?(Regexp) }

      allowed_deprecations.any? { |regex| regex =~ message } ||
        procs.any? { |proc| proc.call(message, callstack) }
    end

    def normalize_message(message)
      Configuration
        .message_normalizers
        .reduce(message) { |message, normalizer| normalizer.call(message) }
    end
  end
end
