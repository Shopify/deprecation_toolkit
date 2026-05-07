# frozen_string_literal: true

require "test_helper"
require "tmpdir"

module DeprecationToolkit
  class ReadWriteHelperTest < ActiveSupport::TestCase
    include TestDeprecator

    Helper = Object.new.extend(ReadWriteHelper)

    setup do
      @previous_deprecation_path = Configuration.deprecation_path
      @previous_behavior = Configuration.behavior
      @previous_normalize = Configuration.deprecation_test_name_normalize
      @deprecation_path = Dir.mktmpdir
      Configuration.behavior = Behaviors::Record
      Configuration.deprecation_path = @deprecation_path
    end

    teardown do
      Configuration.behavior = @previous_behavior
      Configuration.deprecation_path = @previous_deprecation_path
      Configuration.deprecation_test_name_normalize = @previous_normalize
      FileUtils.rm_rf(@deprecation_path)
    end

    test "read matches by exact name" do
      write_deprecation_file("test_exact_match" => ["DEPRECATION WARNING: Foo"])
      deprecations = read_deprecations("test_exact_match")

      assert_equal ["DEPRECATION WARNING: Foo"], deprecations
    end

    test "read falls back to normalized name match when exact key is missing" do
      Configuration.deprecation_test_name_normalize = proc { |name| name.gsub(/_\[\d+\]/, "") }

      write_deprecation_file("test_something" => ["DEPRECATION WARNING: Bar"])
      deprecations = read_deprecations("test_something_[2]")

      assert_equal ["DEPRECATION WARNING: Bar"], deprecations
    end

    test "read falls back to iterating normalized keys when neither exact nor direct normalized match" do
      Configuration.deprecation_test_name_normalize = proc { |name| name.sub(/_tagged_.*$/, "") }

      write_deprecation_file("test_example_tagged_v1" => ["DEPRECATION WARNING: Baz"])
      deprecations = read_deprecations("test_example_tagged_v2")

      assert_equal ["DEPRECATION WARNING: Baz"], deprecations
    end

    test "read returns empty array when no match found even with normalization" do
      write_deprecation_file("test_unrelated" => ["DEPRECATION WARNING: Qux"])
      deprecations = read_deprecations("test_completely_different")

      assert_equal [], deprecations
    end

    test "write removes stale keys that normalize to the same name" do
      Configuration.deprecation_test_name_normalize = proc { |name| name.gsub(/_\[\d+\]/, "") }

      deprecation_file = write_deprecation_file(
        "test_foo_[1]" => ["DEPRECATION WARNING: Old"],
        "test_bar" => ["DEPRECATION WARNING: Other"],
      )

      deprecations_to_record = { "test_foo_[2]" => ["DEPRECATION WARNING: New"] }
      Helper.write(deprecation_file, deprecations_to_record)

      result = YAML.load_file(deprecation_file)

      refute result.key?("test_foo_[1]")
      assert_equal ["DEPRECATION WARNING: New"], result["test_foo_[2]"]
      assert_equal ["DEPRECATION WARNING: Other"], result["test_bar"]
    end

    test "write does not remove the current key even if it normalizes to itself" do
      Configuration.deprecation_test_name_normalize = proc { |name| name }

      deprecation_file = write_deprecation_file("test_foo" => ["DEPRECATION WARNING: Existing"])

      deprecations_to_record = { "test_foo" => ["DEPRECATION WARNING: Updated"] }
      Helper.write(deprecation_file, deprecations_to_record)

      result = YAML.load_file(deprecation_file)

      assert_equal ["DEPRECATION WARNING: Updated"], result["test_foo"]
    end

    private

    def write_deprecation_file(data)
      path = Pathname(@deprecation_path).join("deprecation_toolkit/read_write_helper_test.yml")
      path.dirname.mkpath
      path.write(YAML.dump(data))
      path
    end

    def read_deprecations(test_name)
      fake_test = create_fake_test(test_name)
      Helper.read(fake_test)
    end

    def create_fake_test(test_name)
      klass = Class.new(ActiveSupport::TestCase)
      klass.define_method(:class_name) { "DeprecationToolkit::ReadWriteHelperTest" }

      def klass.name
        "DeprecationToolkit::ReadWriteHelperTest"
      end
      klass.new(test_name)
    end
  end
end
