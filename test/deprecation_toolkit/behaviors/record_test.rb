# frozen_string_literal: true

require "test_helper"
require "tmpdir"

module DeprecationToolkit
  module Behaviors
    class RecordTest < ActiveSupport::TestCase
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
          ActiveSupport::Deprecation.warn("Foo")
          ActiveSupport::Deprecation.warn("Bar")

          trigger_deprecation_toolkit_behavior
        end
      end

      test ".trigger record deprecations for proc path" do
        Configuration.deprecation_path = proc do
          File.join(@deprecation_path, "prefix")
        end

        assert_deprecations_recorded("Foo", to: "#{@deprecation_path}/prefix") do
          ActiveSupport::Deprecation.warn("Foo")

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
          ActiveSupport::Deprecation.warn("Foo")
          ActiveSupport::Deprecation.warn("Bar")

          trigger_deprecation_toolkit_behavior
        end

        assert_deprecations_recorded("Foo") do
          ActiveSupport::Deprecation.warn("Foo")

          trigger_deprecation_toolkit_behavior
        end
      end

      test ".trigger removes the deprecation file when all deprecations were removed" do
        assert_deprecations_recorded("Foo") do
          ActiveSupport::Deprecation.warn("Foo")

          trigger_deprecation_toolkit_behavior
        end

        assert_raises Errno::ENOENT do
          assert_deprecations_recorded("Foo") { trigger_deprecation_toolkit_behavior }
        end
      end

      private

      def assert_deprecations_recorded(*deprecation_triggered, to: @deprecation_path)
        yield

        recorded = YAML.load_file("#{to}/deprecation_toolkit/behaviors/record_test.yml").fetch(name)
        triggered = deprecation_triggered.map { |msg| "DEPRECATION WARNING: #{msg}" }

        assert_equal(recorded, triggered)
      end
    end
  end
end
