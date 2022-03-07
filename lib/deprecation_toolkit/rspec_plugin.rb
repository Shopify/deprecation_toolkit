# frozen_string_literal: true

module DeprecationToolkit
  module RSpecPlugin
    RSpec.configure do |config|
      config.before(:suite) do
        case ENV["DEPRECATION_BEHAVIOR"]
        when "r", "record", "record-deprecations"
          DeprecationToolkit::Configuration.behavior = DeprecationToolkit::Behaviors::Record
        end

        DeprecationToolkit.add_notify_behavior
        DeprecationToolkit.attach_subscriber
      end
    end
  end
end
