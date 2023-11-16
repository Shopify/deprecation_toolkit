# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "deprecation_toolkit"

require "minitest/autorun"
require "active_support/all"
require_relative "support/test_deprecator"

ActiveSupport::Deprecation.behavior = :silence
ActiveSupport::TestCase.test_order = :random

# This is needed so that when we run the tests in this project, and the plugin is initialized by Minitest, we don't
# cause a deprecation warning by calling `ActiveSupport::Deprecation.behavior` and `.behavior=`.
module Rails
  def self.application
    Application
  end

  module Application
    def self.deprecators
      DeprecatorSet
    end
  end

  module DeprecatorSet
    def self.each
    end

    def self.behavior=(behavior)
    end
  end
end
