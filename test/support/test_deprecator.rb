# frozen_string_literal: true

module TestDeprecator
  class << self
    def deprecator
      @deprecator ||= ActiveSupport::Deprecation.new("next version", "test deprecator").tap do |deprecator|
        deprecator.behavior = :notify
        # `ActiveSupport::Subscriber.attach_to` can only be called once (or there will be duplicate deprecations) and
        # with this singleton method we can ensure that.
        DeprecationToolkit::DeprecationSubscriber.attach_to("test deprecator")
      end
    end
  end

  def deprecator
    TestDeprecator.deprecator
  end
end
