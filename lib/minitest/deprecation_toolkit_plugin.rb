# frozen_string_literal: true

module Minitest
  extend self

  def plugin_deprecation_toolkit_options(opts, options)
    opts.on "-r", "--record-deprecations", "Record deprecations" do
      options[:record_deprecations] = true
    end
  end

  def plugin_deprecation_toolkit_init(options)
    if options[:record_deprecations]
      DeprecationToolkit::Configuration.behavior = DeprecationToolkit::Behaviors::Record
    end

    DeprecationToolkit.initialize
  end
end
