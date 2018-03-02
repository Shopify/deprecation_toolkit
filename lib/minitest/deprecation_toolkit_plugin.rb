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

    add_notify_behavior
    attach_subscriber
  end

  private

  def add_notify_behavior
    notify = ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:notify]
    behaviors = ActiveSupport::Deprecation.behavior

    unless behaviors.find { |behavior| behavior == notify }
      ActiveSupport::Deprecation.behavior = behaviors << notify
    end
  end

  def attach_subscriber
    DeprecationToolkit::Configuration.attach_to.each do |gem_name|
      DeprecationToolkit::DeprecationSubscriber.attach_to gem_name
    end
  end
end
