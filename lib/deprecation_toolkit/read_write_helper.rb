# frozen_string_literal: true

require "active_support/core_ext/string/inflections"
require "active_support/core_ext/string/filters"
require "bundler"
require "yaml"

module DeprecationToolkit
  module ReadWriteHelper
    def read(test)
      deprecation_file = Bundler.root.join(recorded_deprecations_path(test))
      YAML.load(deprecation_file.read).fetch(test_name(test), [])
    rescue Errno::ENOENT
      []
    end

    def write(deprecation_file, deprecations_to_record)
      original_deprecations = deprecation_file.exist? ? YAML.load_file(deprecation_file) : {}
      updated_deprecations = original_deprecations.dup

      deprecations_to_record.each do |test, deprecation_to_record|
        if deprecation_to_record.any?
          updated_deprecations[test] = deprecation_to_record
        else
          updated_deprecations.delete(test)
        end
      end

      if updated_deprecations.any?
        if updated_deprecations != original_deprecations
          deprecation_file.dirname.mkpath
          deprecation_file.write(YAML.dump(updated_deprecations.sort.to_h))
        end
      elsif deprecation_file.exist?
        deprecation_file.delete
      end
    end

    private

    def recorded_deprecations_path(test)
      deprecation_folder = if Configuration.deprecation_path.is_a?(Proc)
        Configuration.deprecation_path.call(test_location(test))
      else
        Configuration.deprecation_path
      end

      path = Configuration.deprecation_file_path_format.call(test)

      Pathname(deprecation_folder).join("#{path}.yml")
    end

    def test_location(test)
      Kernel.const_source_location(test.class.name)[0]
    rescue NameError
      "unknown"
    end

    def test_name(test)
      if DeprecationToolkit::Configuration.test_runner == :rspec
        "test_" + test.full_description.underscore.squish.tr(" ", "_")
      else
        test.name
      end
    end
  end
end
