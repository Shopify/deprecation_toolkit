# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "deprecation_toolkit"

require "minitest/autorun"
require "active_support/all"
require_relative "support/test_deprecator"
require_relative "support/fake_rails"

ActiveSupport::Deprecation.behavior = :silence
ActiveSupport::TestCase.test_order = :random
