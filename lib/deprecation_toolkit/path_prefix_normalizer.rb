# frozen_string_literal: true

require "pathname"

module DeprecationToolkit
  class PathPrefixNormalizer
    attr_reader :path_prefixes, :replacement

    def initialize(*path_prefixes, replacement: "")
      @path_prefixes = path_prefixes.compact.map do |path_prefix|
        raise ArgumentError, "path prefixes must be absolute: #{path_prefix}" unless Pathname.new(path_prefix).absolute?

        ending_in_separator(path_prefix)
      end.sort_by { |path| -path.length }
      @replacement = replacement.empty? ? replacement : ending_in_separator(replacement)
    end

    def call(message)
      message.gsub(pattern, replacement)
    end

    def to_s
      "s#{pattern}#{replacement}"
    end

    def pattern
      # Naively anchor to the start of a path.
      # The last character of each segment of a path is likely to match /\w/.
      # Therefore, if the preceeding character does not match /w/, we're probably not in in the middle of a path.
      # e.g. In a containerized environment, we may be given `/app` as a path prefix (perhaps from Rails.root).
      #      Given the following path:                       `/app/components/foo/app/models/bar.rb`,
      #      we should replace the prefix, producing:             `components/foo/app/models/bar.rb`,
      #      without corrupting other occurences:                 `components/foomodels/bar.rb`
      @pattern ||= /(?<!\w)#{Regexp.union(path_prefixes)}/
    end

    def ending_in_separator(path)
      File.join(path, "")
    end
  end
end
