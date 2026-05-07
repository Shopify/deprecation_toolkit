# frozen_string_literal: true

require "minitest"

if Minitest.respond_to?(:load) && !Minitest.extensions.include?("deprecation_toolkit")
  Minitest.load(:deprecation_toolkit)
end

module DeprecationToolkit
  module Minitest
    def trigger_deprecation_toolkit_behavior
      DeprecationToolkit::TestTriggerer.trigger_deprecation_toolkit_behavior(self)
    end
  end
end

module Minitest
  class Test
    include DeprecationToolkit::Minitest

    TEARDOWN_METHODS << "trigger_deprecation_toolkit_behavior"
  end
end
