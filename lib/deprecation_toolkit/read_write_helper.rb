# frozen_string_literal: true

require "active_support/core_ext/string/inflections"
require "yaml"

module DeprecationToolkit
  module ReadWriteHelper
    def read(test)
      deprecation_file = recorded_deprecations_path(test)
      YAML.load(deprecation_file.read).fetch(test.name, [])
    rescue Errno::ENOENT
      []
    end

    def write(test, deprecations)
      deprecation_file = recorded_deprecations_path(test)
      create_deprecation_file(deprecation_file) unless deprecation_file.exist?

      content = YAML.load_file(deprecation_file)
      if deprecations.any?
        content[test.name] = deprecations
      else
        content.delete(test.name)
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

      Bundler.root.join(deprecation_folder, "#{test.class.name.underscore}.yml")
    end

    def test_location(test)
      test.method(test.name).source_location[0]
    rescue NameError
      "unknown"
    end
  end
end
