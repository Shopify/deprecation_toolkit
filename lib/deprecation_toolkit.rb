# frozen_string_literal: true

module DeprecationToolkit
  autoload :DeprecationSubscriber,     "deprecation_toolkit/deprecation_subscriber"
  autoload :Configuration,             "deprecation_toolkit/configuration"
  autoload :Collector,                 "deprecation_toolkit/collector"
  autoload :ReadWriteHelper,           "deprecation_toolkit/read_write_helper"

  module Behaviors
    autoload :Disabled,                "deprecation_toolkit/behaviors/disabled"
    autoload :Raise,                   "deprecation_toolkit/behaviors/raise"
    autoload :Record,                  "deprecation_toolkit/behaviors/record"
  end
end

require "deprecation_toolkit/minitest_hook"
require "deprecation_toolkit/warning"
