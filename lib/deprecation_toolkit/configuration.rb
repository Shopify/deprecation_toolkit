# frozen_string_literal: true

module DeprecationToolkit
  module Configuration
    @allowed_deprecations = []
    singleton_class.attr_accessor(:allowed_deprecations)

    @attach_to = [:rails]
    singleton_class.attr_accessor(:attach_to)

    @behavior = Behaviors::Raise
    singleton_class.attr_accessor(:behavior)

    @deprecation_path = "test/deprecations"
    singleton_class.attr_accessor(:deprecation_path)

    @test_runner = :minitest
    singleton_class.attr_accessor(:test_runner)

    @warnings_treated_as_deprecation = []
    singleton_class.attr_accessor(:warnings_treated_as_deprecation)

    @deprecation_file_path_format = proc do |test|
      if DeprecationToolkit::Configuration.test_runner == :rspec
        test.example_group.file_path.sub(%r{^./spec/}, "").sub(/_spec.rb$/, "")
      else
        test.class.name.underscore
      end
    end
    singleton_class.attr_accessor(:deprecation_file_path_format)

    class << self
      def configure
        yield self
      end

      def config
        self
      end
    end
  end
end
