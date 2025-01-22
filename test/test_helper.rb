# frozen_string_literal: true

# Necessary for activesupport (~> 7.0.0) + concurrent-ruby (1.3.5)
require "logger"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "deprecation_toolkit"

require "minitest/autorun"
require "active_support/all"
require_relative "support/test_deprecator"
require_relative "support/fake_rails"

if ActiveSupport.respond_to?(:deprecator)
  ActiveSupport.deprecator.behavior = :raise
else
  ActiveSupport::Deprecation.behavior = :raise
end
ActiveSupport::TestCase.test_order = :random
