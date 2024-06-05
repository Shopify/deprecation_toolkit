# frozen_string_literal: true

module DeprecationToolkit
  module Warning
    extend self

    @buffer = nil

    # Ruby 2.7 has two warnings for improper use of keyword arguments that are sent in two parts
    # Example:
    #
    # /path/to/caller.rb:1: warning: Using the last argument as keyword parameters is deprecated; \
    # maybe ** should be added to the call
    # /path/to/calleee.rb:1: warning: The called method `method_name' is defined here
    #
    # /path/to/caller.rb:1: warning: Passing the keyword argument as the last hash parameter is deprecated
    # /path/to/calleee.rb:1: warning: The called method `method_name' is defined here
    def two_part_warning?(str)
      str.end_with?(
        "maybe ** should be added to the call\n",
        "Passing the keyword argument as the last hash parameter is deprecated\n",
      )
    end

    def handle_multipart(str)
      if @buffer
        str = @buffer + str
        @buffer = nil
        return str
      end

      if two_part_warning?(str)
        @buffer = str
        return
      end

      str
    end

    def deprecation_triggered?(str)
      DeprecationToolkit::Configuration.warnings_treated_as_deprecation.any? { |warning| warning === str }
    end

    def deprecator
      @deprecator ||= ActiveSupport::Deprecation.new("next", "DeprecationToolkit::Warning").tap do |deprecator|
        deprecator.behavior = :notify
        DeprecationSubscriber.attach_to(:deprecation_toolkit_warning)
      end
    end
  end

  module WarningPatch
    def warn(str, *)
      if Configuration.warnings_treated_as_deprecation.empty?
        return super
      end

      str = DeprecationToolkit::Warning.handle_multipart(str)
      return unless str

      if DeprecationToolkit::Warning.deprecation_triggered?(str)
        DeprecationToolkit::Warning.deprecator.warn(str)
      else
        super
      end
    end
    ruby2_keywords :warn
  end

  ::Warning.singleton_class.prepend(WarningPatch)
end
