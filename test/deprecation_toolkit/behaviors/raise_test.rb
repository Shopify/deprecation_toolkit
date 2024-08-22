# frozen_string_literal: true

require "test_helper"

module DeprecationToolkit
  module Behaviors
    class RaiseTest < ActiveSupport::TestCase
      include TestDeprecator

      setup do
        @previous_configuration = Configuration.behavior
        Configuration.behavior = Raise
      end

      teardown do
        # ensure we don't get warnings for missing assertions
        pass # we have assertions in trigger_deprecation_toolkit_behavior
        Configuration.behavior = @previous_configuration
      end

      test ".trigger raises an DeprecationIntroduced error when deprecations are introduced" do
        @expected_exception_class = DeprecationIntroduced
        @expected_exception_message =
          /DEPRECATION\ WARNING\:\ Foo\ \(called\ from\ .*\nDEPRECATION\ WARNING\:\ Bar\ \(called from\ .*/

        deprecator.warn("Foo")
        deprecator.warn("Bar")
      end

      test ".trigger raises a DeprecationRemoved error when deprecations are removed" do
        @expected_exception_class = DeprecationRemoved
        @expected_exception_message = <<~EOM
          You have removed deprecations from the codebase. Thanks for being an awesome person.
          The recorded deprecations needs to be updated to reflect your changes.
          You can re-record deprecations by adding the `--record-deprecations` flag when running your tests.

          DEPRECATION WARNING: Bar
        EOM

        deprecator.warn("Foo")
      end

      test ".trigger raises a DeprecationRemoved when less deprecations than expected are triggerd and mismatches" do
        @expected_exception_class = DeprecationRemoved
        @expected_exception_message = <<~EOM
          You have removed deprecations from the codebase. Thanks for being an awesome person.
          The recorded deprecations needs to be updated to reflect your changes.
          You can re-record deprecations by adding the `--record-deprecations` flag when running your tests.

          DEPRECATION WARNING: A
          DEPRECATION WARNING: B
        EOM

        deprecator.warn("C")
      end

      test ".trigger raises a DeprecationMismatch when same number of deprecations are triggered with mismatches" do
        @expected_exception_class = DeprecationMismatch
        @expected_exception_message = @expected_exception_message_template = <<~EOM
          The recorded deprecations for this test doesn't match the one that got triggered.
          Fix or record the new deprecations to discard this error.

          You can re-record deprecations by adding the `--record-deprecations` flag when running your tests.

          ===== Expected
          DEPRECATION WARNING: C
          ===== Actual
          DEPRECATION WARNING: A
        EOM

        deprecator.warn("A")
      end

      test ".trigger does not raise when deprecations are triggered but were already recorded" do
        assert_nothing_raised do
          deprecator.warn("Foo")
          deprecator.warn("Bar")
        end
      end

      test ".trigger does not raise when deprecations are allowed with Regex" do
        @old_allowed_deprecations = Configuration.allowed_deprecations
        Configuration.allowed_deprecations = [/John Doe/]

        begin
          deprecator.warn("John Doe")
          assert_nothing_raised { trigger_deprecation_toolkit_behavior }
        ensure
          Configuration.allowed_deprecations = @old_allowed_deprecations
        end
      end

      test ".trigger does not raise when deprecations are allowed with Procs" do
        class_eval <<-RUBY, "my_file.rb", 1337
          def deprecation_caller
            deprecation_callee
          end

          def deprecation_callee
            deprecator = ActiveSupport::Deprecation.new
            deprecator.behavior = :notify
            deprecator.warn("John Doe")
          end
        RUBY

        old_allowed_deprecations = Configuration.allowed_deprecations
        Configuration.allowed_deprecations = [
          ->(_, stack) { stack.first.to_s =~ /my_file\.rb/ },
        ]

        begin
          deprecation_caller
          assert_nothing_raised { trigger_deprecation_toolkit_behavior }
        ensure
          Configuration.allowed_deprecations = old_allowed_deprecations
        end
      end

      test ".trigger does not raise when test is flaky" do
        assert_nothing_raised do
          deprecator.warn("Foo")
          deprecator.warn("Bar")
        end
      end

      def trigger_deprecation_toolkit_behavior
        super
        flunk if defined?(@expected_exception_class)
      rescue DeprecationIntroduced, DeprecationRemoved, DeprecationMismatch => e
        assert_equal(@expected_exception_class, e.class)
        case @expected_exception_message
        when String
          assert_equal(@expected_exception_message, e.message)
        when Regexp
          assert_match(@expected_exception_message, e.message)
        end
      end
    end
  end
end
