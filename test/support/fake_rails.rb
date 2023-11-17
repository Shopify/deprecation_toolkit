# frozen_string_literal: true

# This is needed so that when we run the tests in this project, and the plugin is initialized by Minitest, we don't
# cause a deprecation warning by calling `ActiveSupport::Deprecation.behavior` and `.behavior=`.
module Rails
  def self.application
    Application
  end

  module Application
    def self.deprecators
      @deprecators ||= DeprecatorSet.new
    end
  end

  class DeprecatorSet
    def initialize
      @deprecator = ActiveSupport::Deprecation.new
      @deprecator.behavior = :raise
    end

    def each
      return to_enum unless block_given?

      yield @deprecator
    end

    def behavior=(behavior)
    end
  end
end
