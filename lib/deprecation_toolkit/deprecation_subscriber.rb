# frozen_string_literal: true

require "active_support/subscriber"

module DeprecationToolkit
  class DeprecationSubscriber < ActiveSupport::Subscriber
    class << self
      def already_attached?
        notifier != nil
      end
    end

    def deprecation(event)
      message = event.payload[:message]

      Collector.collect(message) unless deprecation_allowed?(event.payload)
    end

    private

    def deprecation_allowed?(payload)
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
