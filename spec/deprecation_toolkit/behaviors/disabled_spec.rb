# frozen_string_literal: true

require "spec_helper"

RSpec.describe(DeprecationToolkit::Behaviors::Raise) do
  include TestDeprecator

  before do
    @previous_configuration = DeprecationToolkit::Configuration.behavior
    DeprecationToolkit::Configuration.behavior = DeprecationToolkit::Behaviors::Disabled
  end

  after do
    DeprecationToolkit::Configuration.behavior = @previous_configuration
  end

  it ".trigger noop any deprecations" do |example|
    expect do
      deprecator.warn("Foo")
      deprecator.warn("Bar")

      DeprecationToolkit::TestTriggerer.trigger_deprecation_toolkit_behavior(example)
    end.not_to(raise_error)
  end
end
