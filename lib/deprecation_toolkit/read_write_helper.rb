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
