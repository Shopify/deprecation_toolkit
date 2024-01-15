# frozen_string_literal: true

require "test_helper"
require "tmpdir"

module DeprecationToolkit
  module Behaviors
    class RecordTest < ActiveSupport::TestCase
      include TestDeprecator

      setup do
        @previous_deprecation_path = Configuration.deprecation_path
        @deprecation_path = Dir.mktmpdir
        @previous_behavior = Configuration.behavior
        Configuration.behavior = Record
        Configuration.deprecation_path = @deprecation_path
      end

      teardown do
        Configuration.behavior = @previous_behavior
        Configuration.deprecation_path = @previous_deprecation_path
        FileUtils.rm_rf(@deprecation_path)
      end

      test ".trigger record deprecations" do
        assert_deprecations_recorded("Foo", "Bar") do
          deprecator.warn("Foo")
          deprecator.warn("Bar")

          trigger_deprecation_toolkit_behavior
        end
      end

      test ".trigger record deprecations records using file path when configuration is set to use file path" do
        Configuration.deprecation_file_path_format = ->(test) do
          Kernel.const_source_location(test.class.name)[0].sub(%r{^.*/(test/)}, '\1').sub(/\.[^.]+$/, "")
        end

        assert_deprecations_recorded("Foo", "Bar", path: "test/deprecation_toolkit/behaviors/record_test.yml") do
          deprecator.warn("Foo")
          deprecator.warn("Bar")

          trigger_deprecation_toolkit_behavior
        end
      ensure
        Configuration.deprecation_file_path_format = proc do |test|
          if DeprecationToolkit::Configuration.test_runner == :rspec
            test.example_group.file_path.sub(%r{^./spec/}, "").sub(/_spec.rb$/, "")
          else
            test.class.name.underscore
          end
        end
      end

      test ".trigger record deprecations for proc path" do
        Configuration.deprecation_path = proc do
          File.join(@deprecation_path, "prefix")
        end

        assert_deprecations_recorded("Foo", to: "#{@deprecation_path}/prefix") do
          deprecator.warn("Foo")

          trigger_deprecation_toolkit_behavior
        end
      end

      class_eval(<<~RUBY, "some_other_file.rb", 1)
        test ".trigger record deprecations for proc path with correct test location" do
          Configuration.deprecation_path = proc do |test_location|
            assert_match(%r(test/deprecation_toolkit/behaviors/record_test.rb), test_location)

            @deprecation_path
          end

          trigger_deprecation_toolkit_behavior
        end
      RUBY

      test ".trigger re-record an existing deprecation file" do
        assert_deprecations_recorded("Foo", "Bar") do
          deprecator.warn("Foo")
          deprecator.warn("Bar")

          trigger_deprecation_toolkit_behavior
        end

        assert_deprecations_recorded("Foo") do
          deprecator.warn("Foo")

          trigger_deprecation_toolkit_behavior
        end
      end

      test ".trigger removes the deprecation file when all deprecations were removed" do
        assert_deprecations_recorded("Foo") do
          deprecator.warn("Foo")

          trigger_deprecation_toolkit_behavior
        end

        assert_raises Errno::ENOENT do
          assert_deprecations_recorded("Foo") { trigger_deprecation_toolkit_behavior }
        end
      end

      test ".trigger records deprecations without stack trace even for Gem::Deprecate" do
        previous_warnings_treated_as_deprecation = Configuration.warnings_treated_as_deprecation
        Configuration.warnings_treated_as_deprecation = [/#example is deprecated/]

        # produce a Gem::Deprecate warning
        dummy = Class.new do
          extend Gem::Deprecate
          def example; end
          deprecate :example, :new_example, 2019, 1
        end
        dummy.new.example
        trigger_deprecation_toolkit_behavior

        recorded_deprecation = recorded_deprecations.first

        assert_match(/.*#example is deprecated; use new_example instead\./, recorded_deprecation)
        refute_match(/called from/, recorded_deprecation)

      ensure
        Configuration.warnings_treated_as_deprecation = previous_warnings_treated_as_deprecation
      end

      private

      def assert_deprecations_recorded(
        *deprecation_triggered,
        to: @deprecation_path,
        path: "deprecation_toolkit/behaviors/record_test.yml"
      )
        yield

        triggered = deprecation_triggered.map { |msg| "DEPRECATION WARNING: #{msg}" }

        assert_equal(recorded_deprecations(to: to, path: path), triggered)
      end

      def recorded_deprecations(to: @deprecation_path, path: "deprecation_toolkit/behaviors/record_test.yml")
        YAML.load_file("#{to}/#{path}").fetch(name)
      end
    end
  end
end
