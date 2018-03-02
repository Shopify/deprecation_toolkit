# frozen_string_literal: true

require "active_support/subscriber"

module DeprecationToolkit
  class DeprecationSubscriber < ActiveSupport::Subscriber
    def deprecation(event)
      message = event.payload[:message]

      Collector.collect(message) unless deprecation_allowed?(message)
    end

    private

    def deprecation_allowed?(message)
      Configuration.allowed_deprecations.any? { |regex| regex =~ message }
    end
  end
end
