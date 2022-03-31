# frozen_string_literal: true

require "test_helper"

module DeprecationToolkit
  class WarningTest < ActiveSupport::TestCase
    setup do
      @previous_warnings_treated_as_deprecation = Configuration.warnings_treated_as_deprecation
    end

    teardown do
      Configuration.warnings_treated_as_deprecation = @previous_warnings_treated_as_deprecation
    end

    test "treats warnings as deprecations" do
      Configuration.warnings_treated_as_deprecation = [/#example is deprecated/]

      assert_raises Behaviors::DeprecationIntroduced do
        warn "#example is deprecated"

        trigger_deprecation_toolkit_behavior
      end
    end

    test "Kernel.warn treats warnings as deprecations " do
      Configuration.warnings_treated_as_deprecation = [/#example is deprecated/]

      assert_raises Behaviors::DeprecationIntroduced do
        Kernel.warn("#example is deprecated")

        trigger_deprecation_toolkit_behavior
      end
    end

    test "warn can be called with an array" do
      Configuration.warnings_treated_as_deprecation = [/#example is deprecated/, /#something is deprecated/]

      error = assert_raises(Behaviors::DeprecationIntroduced) do
        warn(["#example is deprecated", "#something is deprecated"])

        trigger_deprecation_toolkit_behavior
      end

      assert_match(/DEPRECATION WARNING: #example is deprecated/, error.message)
      assert_match(/#something is deprecated/, error.message)
    end

    test "warn can be called with multiple arguments" do
      Configuration.warnings_treated_as_deprecation = [/#example is deprecated/, /#something is deprecated/]

      error = assert_raises(Behaviors::DeprecationIntroduced) do
        warn("#example is deprecated", "#something is deprecated")

        trigger_deprecation_toolkit_behavior
      end

      assert_match(/DEPRECATION WARNING: #example is deprecated/, error.message)
      assert_match(/#something is deprecated/, error.message)
    end

    test "warn works as usual when no warnings are treated as deprecation" do
      std_out, stderr = capture_io do
        assert_nothing_raised do
          warn("Test warn works correctly")
        end
      end
      assert_empty std_out
      assert_equal "Test warn works correctly\n", stderr
    end

    test "Ruby 2.7 two-part keyword argument warning are joined together" do
      Configuration.warnings_treated_as_deprecation = [/Using the last argument as keyword parameters/]

      error = assert_raises(Behaviors::DeprecationIntroduced) do
        warn("/path/to/caller.rb:1: warning: Using the last argument as keyword parameters is deprecated; " \
          "maybe ** should be added to the call")
        warn("/path/to/calleee.rb:1: warning: The called method `method_name' is defined here")

        trigger_deprecation_toolkit_behavior
      end

      assert_match(/Using the last argument as keyword parameters/, error.message)
      assert_match(/The called method/, error.message)
    end

    test "'Ruby 2.7 last argument as keyword parameters' real deprecation warning is handled with normalized paths" do
      Configuration.warnings_treated_as_deprecation = [/Using the last argument as keyword parameters/]

      error = assert_raises(Behaviors::DeprecationIntroduced) do
        warn("#{Dir.pwd}/path/to/caller.rb:1: warning: Using the last argument as keyword parameters is deprecated; " \
          "maybe ** should be added to the call")
        warn("#{Dir.pwd}/path/to/callee.rb:1: warning: The called method `method_name' is defined here")

        trigger_deprecation_toolkit_behavior
      end

      assert_match(%r{^DEPRECATION WARNING: path/to/caller\.rb:1: warning: Using the last},
        error.message)
      assert_match(%r{^path/to/callee\.rb:1: warning: The called method}, error.message)
    end

    test "`assert_nil` real deprecation warning is handled with normalized paths" do
      Configuration.warnings_treated_as_deprecation = [/Use assert_nil if expecting nil/]

      error = assert_raises(Behaviors::DeprecationIntroduced) do
        warn("Use assert_nil if expecting nil from #{Dir.pwd}/path/to/file.rb:1. This will fail in Minitest 6.")

        trigger_deprecation_toolkit_behavior
      end

      assert_match(
        %r{^DEPRECATION WARNING: Use assert_nil if expecting nil from path/to/file\.rb:1}, error.message
      )
    end

    test "the path to warn itself is handled too" do
      Configuration.warnings_treated_as_deprecation = [/boom/]

      error = assert_raises(Behaviors::DeprecationIntroduced) do
        warn("boom")

        trigger_deprecation_toolkit_behavior
      end

      assert_includes(error.message, <<~MESSAGE.chomp)
        DEPRECATION WARNING: boom
         (called from call at <RUBY_INTERNALS>/rubygems/core_ext/kernel_warn.rb:22)
      MESSAGE
    end

    test "Rails.root is normalized in deprecation messages" do
      rails_stub = Object.new
      rails_stub.define_singleton_method(:inspect) { "Rails (stub)" }
      rails_stub.define_singleton_method(:root) { "/path/to/rails/root" }

      original_rails = defined?(::Rails) && ::Rails
      Object.const_set(:Rails, rails_stub)

      assert_normalizes(
        from: "#{Rails.root}/app/models/whatever.rb",
        to: "app/models/whatever.rb",
      )
    ensure
      if original_rails.nil?
        Object.send(:remove_const, :Rails)
      else
        Object.const_set(:Rails, original_rails)
      end
    end

    test "Bundler.root is normalized in deprecation messages" do
      assert_normalizes(
        from: "#{Bundler.root}/lib/whatever.rb",
        to: "lib/whatever.rb",
      )
    end

    test "Gem spec gem_dirs are normalized in deprecation messages" do
      spec = Gem.loaded_specs.each_value.first
      assert_normalizes(
        from: "#{spec.gem_dir}/lib/whatever.rb",
        to: "<GEM_DIR:#{spec.name}>/lib/whatever.rb",
      )
    end

    test "Gem spec extension_dirs are normalized in deprecation messages" do
      spec = Gem.loaded_specs.each_value.first
      assert_normalizes(
        from: "#{spec.extension_dir}/lib/whatever.rb",
        to: "<GEM_EXTENSION_DIR:#{spec.name}>/lib/whatever.rb",
      )
    end

    test "Gem spec bin_dirs are normalized in deprecation messages" do
      spec = Gem.loaded_specs.each_value.first
      assert_normalizes(
        from: "#{spec.bin_dir}/lib/whatever.rb",
        to: "<GEM_BIN_DIR:#{spec.name}>/lib/whatever.rb",
      )
    end

    test "Gem paths are normalized in deprecation messages" do
      paths = Gem.path
      puts
      puts
      pp Configuration.message_normalizers
      puts
      pp paths # TODO: Remove this (debugging CI)
      puts
      puts
      assert_normalizes(
        from: paths.map.with_index { |path, index| "#{path}/file-#{index}" }.join("\n"),
        to: Array.new(paths.length) { |index| "<GEM_PATH>/file-#{index}" }.join("\n"),
      )
    end

    test "RbConfig paths are normalized in deprecation messages" do
      paths = RbConfig::CONFIG.values_at("prefix", "sitelibdir", "rubylibdir").compact
      assert_normalizes(
        from: paths.map.with_index { |path, index| "#{path}/file-#{index}" }.join("\n"),
        to: Array.new(paths.length) { |index| "<RUBY_INTERNALS>/file-#{index}" }.join("\n"),
      )
    end

    private

    def assert_normalizes(from:, to:)
      Configuration.warnings_treated_as_deprecation = [/test deprecation/]
      error = assert_raises(Behaviors::DeprecationIntroduced) do
        warn("test deprecation: #{from}.")
        trigger_deprecation_toolkit_behavior
      end
      assert_includes(error.message, to)
    end
  end
end
