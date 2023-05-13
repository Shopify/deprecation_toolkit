# frozen_string_literal: true

require "test_helper"

module DeprecationToolkit
  class ConfigurationTest < ActiveSupport::TestCase
    setup do
      @previous_warning_deprecated = ::Warning[:deprecated]
      @previous_warning_deprecated_category = Configuration.warning_deprecated_category
    end

    teardown do
      Configuration.warning_deprecated_category = @previous_warning_deprecated_category
      ::Warning[:deprecated] = @previous_warning_deprecated
    end

    test ".behavior is by default set to Raise" do
      assert_equal Behaviors::Raise, Configuration.behavior
    end

    test ".allowed_deprecations is by default empty" do
      assert_empty Configuration.allowed_deprecations
    end

    test ".deprecation_path is by default set to `test/deprecations`" do
      assert_equal "test/deprecations", Configuration.deprecation_path
    end

    test ".attach_to is by default set to `rails`" do
      assert_equal [:rails], Configuration.attach_to
    end

    test ".test_runner is by default set to `minitest`" do
      assert_equal :minitest, Configuration.test_runner
    end

    test ".warning_deprecated_category is by default set to `true`" do
      with_each_warning_deprecated_value do
        assert_equal true, Configuration.warning_deprecated_category
      end
    end

    test ".warning_deprecated_category= sets `Warning[:deprecated]` when passed boolean" do
      with_each_warning_deprecated_value do
        Configuration.warning_deprecated_category = true
        assert_equal true, ::Warning[:deprecated]

        Configuration.warning_deprecated_category = false
        assert_equal false, ::Warning[:deprecated]
      end
    end

    test ".warning_deprecated_category= leaves `Warning[:deprecated]` unchanged when passed nil" do
      with_warning_deprecated false do
        Configuration.warning_deprecated_category = nil
        assert_equal false, ::Warning[:deprecated]

        Configuration.warning_deprecated_category = true
        assert_equal true, ::Warning[:deprecated]

        Configuration.warning_deprecated_category = nil
        assert_equal false, ::Warning[:deprecated]
      end

      with_warning_deprecated true do
        Configuration.warning_deprecated_category = nil
        assert_equal true, ::Warning[:deprecated]

        Configuration.warning_deprecated_category = false
        assert_equal false, ::Warning[:deprecated]

        Configuration.warning_deprecated_category = nil
        assert_equal true, ::Warning[:deprecated]
      end
    end

    private

    def with_warning_deprecated(value)
      previous_value = ::Warning[:deprecated]

      ::Warning[:deprecated] = value

      Configuration.send(:remove_const, :PREVIOUS_WARNING_DEPRECATED_CATEGORY)
      Configuration.const_set(:PREVIOUS_WARNING_DEPRECATED_CATEGORY, ::Warning[:deprecated])

      yield
    ensure
      ::Warning[:deprecated] = previous_value

      Configuration.send(:remove_const, :PREVIOUS_WARNING_DEPRECATED_CATEGORY)
      Configuration.const_set(:PREVIOUS_WARNING_DEPRECATED_CATEGORY, ::Warning[:deprecated])
    end

    def with_each_warning_deprecated_value(&block)
      with_warning_deprecated(false, &block)
      with_warning_deprecated(true, &block)
    end
  end
end
