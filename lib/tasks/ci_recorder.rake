# frozen_string_literal: true

require "tempfile"
require "json"
require "active_support/core_ext/hash"
require "rake"
require_relative "../deprecation_toolkit/read_write_helper"

class CIRecorder
  include Rake::DSL
  include DeprecationToolkit::ReadWriteHelper

  def initialize
    namespace(:deprecation_toolkit) do
      desc("Parse a file generated with the CIOutputHelper and generate deprecations out of it")
      task(:record_from_ci_output) do
        raw_file = ENV.fetch("FILEPATH")

        deprecations = extract_deprecations_output(raw_file) do |file|
          parse_file(file)
        end

        generate_deprecations_file(deprecations)
      end
    end
  end

  private

  def extract_deprecations_output(file)
    tmp_file = Tempfile.new
    shell_command = "cat #{file} | sed -n -e 's/^.* \\[DeprecationToolkit\\] \\(.*\\)/\\1/p' > #{tmp_file.path}"

    raise "Couldn't extract deprecations from output" unless system(shell_command)

    yield(tmp_file)
  ensure
    tmp_file.delete
  end

  def parse_file(file)
    file.each.with_object({}) do |line, hash|
      hash.deep_merge!(JSON.parse(line))
    end
  end

  def generate_deprecations_file(deprecations_to_record)
    deprecations_to_record.each do |filename, deprecations|
      write(Pathname(filename), deprecations)
    end
  end
end

CIRecorder.new
