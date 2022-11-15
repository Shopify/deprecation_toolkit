# frozen_string_literal: true

module Minitest
  extend self

  def plugin_deprecation_toolkit_options(opts, options)
    opts.on("-r", "--record-deprecations", "Record deprecations") do
      options[:record_deprecations] = true
    end
  end

  def plugin_deprecation_toolkit_init(options)
    return unless using_bundler?

    require "deprecation_toolkit"

    if options[:record_deprecations]
      DeprecationToolkit::Configuration.behavior = DeprecationToolkit::Behaviors::Record
    end

    DeprecationToolkit.add_notify_behavior
    DeprecationToolkit.attach_subscriber
  end

  private

  def using_bundler?
    ENV["BUNDLE_GEMFILE"]
  end
end
