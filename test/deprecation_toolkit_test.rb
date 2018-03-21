# frozen_string_literal: true

require "test_helper"

class DeprecationToolkitTest < ActiveSupport::TestCase
  test "no exception raised when no difference between current deprecations and recorded deprecations" do
    assert_nothing_raised do
      ActiveSupport::Deprecation.warn("First deprecation")
      ActiveSupport::Deprecation.warn("Second deprecation")
      ActiveSupport::Deprecation.warn("Third deprecation")
    end
  end

  test "no exception raised when deprecations are allowed" do
    begin
      old_allowed = DeprecationToolkit::Configuration.allowed_deprecations
      DeprecationToolkit::Configuration.allowed_deprecations = [/Hello world/, /My name is John/]

      assert_nothing_raised do
        ActiveSupport::Deprecation.warn("Hello world")
        ActiveSupport::Deprecation.warn("My name is John")
      end
    ensure
      DeprecationToolkit::Configuration.allowed_deprecations = old_allowed
    end
  end
end


class ExceptionExpectedTest < ActiveSupport::TestCase
  attr_accessor :expected_error_class, :deprecations

  test "exception is raised when new deprecations are introduced" do
    @expected_error_class = DeprecationToolkit::Behaviors::DeprecationIntroduced
    @deprecations = [/Fourth deprecation/, /Fifth deprecation/]

    ActiveSupport::Deprecation.warn("First deprecation")
    ActiveSupport::Deprecation.warn("Second deprecation")
    ActiveSupport::Deprecation.warn("Third deprecation")
    ActiveSupport::Deprecation.warn("Fourth deprecation")
    ActiveSupport::Deprecation.warn("Fifth deprecation")
  end

  test "exception is raised when some deprecations are removed" do
    @expected_error_class = DeprecationToolkit::Behaviors::DeprecationRemoved
    @deprecations = [/Third deprecation/]

    ActiveSupport::Deprecation.warn("First deprecation")
    ActiveSupport::Deprecation.warn("Second deprecation")
  end

  def ensure_no_deprecation
    begin
      super
    rescue DeprecationToolkit::Behaviors::DeprecationException => e
      assert_instance_of(@expected_error_class, e)
      @deprecations.each do |expected|
        assert_match(expected, e.message)
      end
    end
  end
end
