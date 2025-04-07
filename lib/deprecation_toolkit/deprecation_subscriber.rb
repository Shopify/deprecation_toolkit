# frozen_string_literal: true

require "active_support/subscriber"

module DeprecationToolkit
  class DeprecationSubscriber < ActiveSupport::Subscriber
    class << self
      def attach_to(gem_name, subscriber = new, notifier = ActiveSupport::Notifications, inherit_all: false)
        return if already_attached_to?(gem_name)

        super(gem_name, subscriber, notifier, inherit_all: inherit_all)
      end

      def detach_from(gem_name, notifier = ActiveSupport::Notifications)
        @namespace  = gem_name
        @subscriber = find_attached_subscriber(gem_name)
        @notifier = notifier

        return unless subscriber

        subscribers.delete(subscriber)

        # Remove event subscribers of all existing methods on the class.
        fetch_public_methods(subscriber, true).each do |event|
          remove_event_subscriber(event)
        end

        @notifier = nil unless any_subscribers_attached?
      end

      private

      def already_attached_to?(gem_name)
        subscribers.any? do |subscriber|
          attached_subscriber?(subscriber, gem_name)
        end
      end

      def any_subscribers_attached?
        subscribers.any? do |subscriber|
          subscriber.is_a?(self)
        end
      end

      def find_attached_subscriber(gem_name)
        subscribers.find do |attached_subscriber|
          attached_subscriber?(attached_subscriber, gem_name)
        end
      end

      def attached_subscriber?(subscriber, gem_name)
        subscriber.is_a?(self) &&
          subscriber.patterns.keys.any? do |pattern|
            pattern.end_with?(".#{gem_name}")
          end
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
