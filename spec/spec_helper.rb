# frozen_string_literal: true

# Necessary for activesupport (~> 7.0.0) + concurrent-ruby (1.3.5)
require "logger"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "deprecation_toolkit"
require "deprecation_toolkit/rspec_plugin"
require "active_support/all"
require_relative "../test/support/test_deprecator"
require_relative "../test/support/fake_rails"

DeprecationToolkit::Configuration.test_runner = :rspec
DeprecationToolkit::Configuration.deprecation_path = "spec/deprecations"

if ActiveSupport.respond_to?(:deprecator)
  ActiveSupport.deprecator.behavior = :raise
else
  ActiveSupport::Deprecation.behavior = :raise
end

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end
end
