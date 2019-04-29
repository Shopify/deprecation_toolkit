# frozen_string_literal: true

require "deprecation_toolkit/rspec_plugin"

RSpec.configure do |config|
  config.after do |example|
    DeprecationToolkit::TestTriggerer.trigger_deprecation_toolkit_behavior(example)
  end
end
