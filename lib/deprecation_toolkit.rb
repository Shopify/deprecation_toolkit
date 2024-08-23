# frozen_string_literal: true

require "active_support"

load("tasks/ci_recorder.rake")

module DeprecationToolkit
  autoload :DeprecationSubscriber,     "deprecation_toolkit/deprecation_subscriber"
  autoload :Configuration,             "deprecation_toolkit/configuration"
  autoload :Collector,                 "deprecation_toolkit/collector"
  autoload :ReadWriteHelper,           "deprecation_toolkit/read_write_helper"
  autoload :TestTriggerer,             "deprecation_toolkit/test_triggerer"

  module Behaviors
    autoload :Disabled,                "deprecation_toolkit/behaviors/disabled"
    autoload :Raise,                   "deprecation_toolkit/behaviors/raise"
    autoload :Record,                  "deprecation_toolkit/behaviors/record"
    autoload :CIRecordHelper,          "deprecation_toolkit/behaviors/ci_record_helper"
  end

  class << self
    def add_notify_behavior
      notify = ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:notify]

      each_deprecator do |deprecator|
        behaviors = deprecator.behavior

        unless behaviors.find { |behavior| behavior == notify }
          deprecator.behavior = (behaviors << notify)
        end
      end
    end

    def attach_subscriber
      return if DeprecationSubscriber.already_attached?

      Configuration.attach_to.each do |gem_name|
        DeprecationSubscriber.attach_to(gem_name)
      end
    end

    private

    def each_deprecator(&block)
      if defined?(Rails.application) && Rails.application.respond_to?(:deprecators)
        Rails.application.deprecators.each(&block)
      elsif ActiveSupport::Deprecation.respond_to?(:behavior)
        block.call(ActiveSupport::Deprecation)
      end
    end
  end
end

require "deprecation_toolkit/minitest_hook" unless defined? RSpec
require "deprecation_toolkit/warning"
