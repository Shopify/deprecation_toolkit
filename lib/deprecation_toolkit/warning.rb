# frozen_string_literal: true

module DeprecationToolkit
  module Warning
    def warn(str)
      if DeprecationToolkit::Configuration.warnings_treated_as_deprecation.any? { |warning| warning =~ str }
        ActiveSupport::Deprecation.warn(str)
      else
        super
      end
    end
  end
end

Warning.singleton_class.prepend(DeprecationToolkit::Warning)

# https://bugs.ruby-lang.org/issues/12944
if Gem::Version.new(ENV['RUBY_VERSION']) <= Gem::Version.new('2.5')
  module Kernel
    def warn(str)
      Warning.warn(str)
    end
  end
end
