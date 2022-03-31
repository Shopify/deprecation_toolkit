# frozen_string_literal: true

require "test_helper"

module DeprecationToolkit
  class PathPrefixNormalizerTest < ActiveSupport::TestCase
    test "can strip a single path prefix" do
      prefix = File.join("", "a")
      normalizer = PathPrefixNormalizer.new(prefix)

      full_path = File.join("", "a", "b", "c")
      normalized_path = File.join("b", "c")

      assert_equal normalized_path, normalizer.call(full_path)
    end

    test "can strip multiple path prefixes" do
      prefixes = [File.join("", "a"), File.join("", "d")]
      normalizer = PathPrefixNormalizer.new(*prefixes)

      full_path = File.join("", "a", "b", "c")
      normalized_path = File.join("b", "c")

      assert_equal normalized_path, normalizer.call(full_path)

      full_path = File.join("", "d", "e", "f")
      normalized_path = File.join("e", "f")

      assert_equal normalized_path, normalizer.call(full_path)
    end

    test "multiple path prefixes are replaced individually, not in succession" do
      prefixes = [File.join("", "a"), File.join("", "d")]
      normalizer = PathPrefixNormalizer.new(*prefixes)

      full_path = File.join("", "a", "b", "c", "d", "e", "f")
      normalized_path = File.join("b", "c", "d", "e", "f")

      assert_equal normalized_path, normalizer.call(full_path)
    end

    test "replacement is customizable" do
      prefix = File.join("", "a")
      normalizer = PathPrefixNormalizer.new(prefix, replacement: File.join("eh", ""))

      full_path = File.join("", "a", "b", "c")
      normalized_path = File.join("eh", "b", "c")

      assert_equal normalized_path, normalizer.call(full_path)
    end

    test "path separator is appended to replacement if not present" do
      prefix = File.join("", "a")
      normalizer = PathPrefixNormalizer.new(prefix, replacement: "eh")

      full_path = File.join("", "a", "b", "c")
      normalized_path = File.join("eh", "b", "c")

      assert_equal normalized_path, normalizer.call(full_path)
    end

    test "path separator is not appended to empty replacement" do
      prefix = File.join("", "a")
      normalizer = PathPrefixNormalizer.new(prefix, replacement: "")

      full_path = File.join("", "a", "b", "c")
      normalized_path = File.join("b", "c")

      assert_equal normalized_path, normalizer.call(full_path)
    end

    test "given prefix is extended to include trailing separator if not present" do
      prefix = File.join("", "a")
      normalizer = PathPrefixNormalizer.new(prefix)

      full_path = File.join("", "a", "b", "c")
      normalized_path = File.join("b", "c")

      assert_equal normalized_path, normalizer.call(full_path)
    end

    test "if given prefix already includes trailing separator, it is not duplicated" do
      prefix = File.join("", "a", "")
      normalizer = PathPrefixNormalizer.new(prefix)

      full_path = File.join("", "a", "b", "c")
      normalized_path = File.join("b", "c")

      assert_equal normalized_path, normalizer.call(full_path)
    end

    test "only path prefixes are replaced, not infixes or suffixes" do
      prefixes = [File.join("", "a"), File.join("", "b"), File.join("", "c")]
      normalizer = PathPrefixNormalizer.new(*prefixes)

      full_path = File.join("", "a", "b", "c", "c", "b", "a")
      normalized_path = File.join("b", "c", "c", "b", "a")

      assert_equal normalized_path, normalizer.call(full_path)
    end

    test "paths are normalized even if in the middle of the given string" do
      prefix = File.join("", "a")
      normalizer = PathPrefixNormalizer.new(prefix)

      original_message = "The code in #{File.join("", "a", "b", "c")} on line 1 is deprecated!"
      normalized_message = "The code in #{File.join("b", "c")} on line 1 is deprecated!"

      assert_equal normalized_message, normalizer.call(original_message)
    end

    test "relative paths are not accepted" do
      prefix = File.join("a", "", "b")

      error = assert_raises(ArgumentError) do
        PathPrefixNormalizer.new(prefix)
      end

      assert_equal "path prefixes must be absolute: #{prefix}", error.message
    end

    test "multiple paths in given string are normalized" do
      prefix = File.join("", "a")
      normalizer = PathPrefixNormalizer.new(prefix)

      original_message = "There are deprecations in #{File.join("", "a", "b")} and #{File.join("", "a", "c")}"
      normalized_message = "There are deprecations in b and c"

      assert_equal normalized_message, normalizer.call(original_message)
    end

    test "matches are as long as possible" do
      prefixes = [File.join("", "a"), File.join("", "a", "b")]
      normalizer = PathPrefixNormalizer.new(*prefixes)

      full_path = File.join("", "a", "b", "c")
      normalized_path = "c"

      assert_equal normalized_path, normalizer.call(full_path)
    end

    test "nil prefixes are ignored" do
      prefixes = [File.join("", "a"), nil]
      normalizer = PathPrefixNormalizer.new(*prefixes)

      full_path = File.join("", "a", "b")
      normalized_path = "b"

      assert_equal normalized_path, normalizer.call(full_path)
    end
  end
end
