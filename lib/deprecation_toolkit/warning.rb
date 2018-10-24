# frozen_string_literal: true

module DeprecationToolkit
  module Warning
    extend self

    def deprecation_triggered?(str)
      DeprecationToolkit::Configuration.warnings_treated_as_deprecation.any? { |warning| warning =~ str }
    end
  end
end

# Warning is a new feature in ruby 2.5
module Warning
  def warn(str)
    if DeprecationToolkit::Warning.deprecation_triggered?(str)
      ActiveSupport::Deprecation.warn(str)
    else
      super
    end
  end
end

# Support for version older < 2.5
# Note that the `Warning` module exists in Ruby 2.4 but has a bug https://bugs.ruby-lang.org/issues/12944
if RUBY_VERSION < '2.5.0' && RUBY_ENGINE == 'ruby'
  module Kernel
    class << self
      alias_method :__original_warn, :warn

      def warn(*messages)
        message = messages.join("\n")
        message += "\n" unless message.end_with?("\n")

        if DeprecationToolkit::Warning.deprecation_triggered?(message)
          ActiveSupport::Deprecation.warn(message)
        else
          __original_warn(messages)
        end
      end
    end

    def warn(*messages)
      Kernel.warn(messages)
    end
  end
end
