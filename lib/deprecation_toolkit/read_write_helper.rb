# frozen_string_literal: true

require "active_support/core_ext/string/inflections"
require "active_support/core_ext/string/filters"
require "bundler"
require "yaml"

module DeprecationToolkit
  module ReadWriteHelper
    def read(test)
      deprecation_file = Bundler.root.join(recorded_deprecations_path(test))
      data = YAML.load(deprecation_file.read)
      name = test_name(test)

      # Fast path: exact match
      return data[name] if data.key?(name)

      # Fallback: match by normalized name (handles tag addition/removal)
      normalized_name = normalized_test_name(name)
      return data[normalized_name] if data.key?(normalized_name)

      # Fallback: iterate over all normalized keys
      data.each do |key, deprecations|
        return deprecations if normalized_test_name(key) == normalized_name
      end

      []
    rescue Errno::ENOENT
      []
    end

    def write(deprecation_file, deprecations_to_record)
      original_deprecations = deprecation_file.exist? ? YAML.load_file(deprecation_file) : {}
      updated_deprecations = original_deprecations.dup

      deprecations_to_record.each do |test, deprecation_to_record|
        # Remove any stale key that normalizes to the same name
        normalized = normalized_test_name(test)
        updated_deprecations.delete_if { |key, _| key != test && normalized_test_name(key) == normalized }

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

    def normalized_test_name(name)
      DeprecationToolkit::Configuration.deprecation_test_name_normalize.call(name)
    end
  end
end
