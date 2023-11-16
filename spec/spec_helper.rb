# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "deprecation_toolkit"
require "deprecation_toolkit/rspec_plugin"
require "active_support/all"
require_relative "../test/support/test_deprecator"

DeprecationToolkit::Configuration.test_runner = :rspec
DeprecationToolkit::Configuration.deprecation_path = "spec/deprecations"
ActiveSupport::Deprecation.behavior = :silence

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with(:rspec) do |c|
    c.syntax = :expect
  end
end
