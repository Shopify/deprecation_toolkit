# frozen_string_literal: true

require "active_support/core_ext/string/inflections"
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
      create_deprecation_file(deprecation_file) unless deprecation_file.exist?

      content = YAML.load_file(deprecation_file)

      deprecations_to_record.each do |test, deprecations|
        if deprecations.any?
          content[test] = deprecations
        else
          content.delete(test)
        end
      end

      if content.any?
        deprecation_file.write(YAML.dump(content))
      else
        deprecation_file.delete
      end
    end

    private

    def create_deprecation_file(deprecation_file)
      deprecation_file.dirname.mkpath
      deprecation_file.write(YAML.dump({}))
    end

    def recorded_deprecations_path(test)
      deprecation_folder = if Configuration.deprecation_path.is_a?(Proc)
        Configuration.deprecation_path.call(test_location(test))
      else
        Configuration.deprecation_path
      end

      path =
        if DeprecationToolkit::Configuration.test_runner == :rspec
          rspec_recorded_deprecations_path(test)
        else
          test.class.name.underscore
        end

      Pathname(deprecation_folder).join("#{path}.yml")
    end

    def test_location(test)
      test.method(test_name(test)).source_location[0]
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

    def rspec_recorded_deprecations_path(test)
      if DeprecationToolkit::Configuration.use_legacy_rspec_recorded_deprecations_path
        test.example_group.file_path.sub(%r{^./spec/}, "").sub(/_spec.rb$/, "")
      else
        test.location_rerun_argument.sub(%r{^./spec/}, "").sub(/_spec.rb:\d*$/, "")
      end
    end
  end
end
