# frozen_string_literal: true

require "active_support"

load("tasks/ci_recorder.rake")

module DeprecationToolkit
  autoload :DeprecationSubscriber,     "deprecation_toolkit/deprecation_subscriber"
  autoload :Configuration,             "deprecation_toolkit/configuration"
  autoload :Collector,                 "deprecation_toolkit/collector"
  autoload :PathPrefixNormalizer,      "deprecation_toolkit/path_prefix_normalizer"
  autoload :ReadWriteHelper,           "deprecation_toolkit/read_write_helper"
  autoload :TestTriggerer,             "deprecation_toolkit/test_triggerer"

  module Behaviors
    autoload :Disabled,                "deprecation_toolkit/behaviors/disabled"
    autoload :Raise,                   "deprecation_toolkit/behaviors/raise"
    autoload :Record,                  "deprecation_toolkit/behaviors/record"
    autoload :CIRecordHelper,          "deprecation_toolkit/behaviors/ci_record_helper"
  end

  def self.add_notify_behavior
    notify = ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:notify]
    behaviors = ActiveSupport::Deprecation.behavior

    unless behaviors.find { |behavior| behavior == notify }
      ActiveSupport::Deprecation.behavior = behaviors << notify
    end
  end

  def self.attach_subscriber
    return if DeprecationSubscriber.already_attached?

    Configuration.attach_to.each do |gem_name|
      DeprecationSubscriber.attach_to(gem_name)
    end
  end
end

require "deprecation_toolkit/minitest_hook" unless defined? RSpec
require "deprecation_toolkit/warning"
