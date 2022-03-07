# frozen_string_literal: true

require "spec_helper"

RSpec.describe(DeprecationToolkit::RSpecPlugin) do
  it "should add `notify` behavior to the deprecations behavior list" do
    behavior = ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:notify]

    expect(ActiveSupport::Deprecation.behavior).to(include(behavior))
  end

  it "doesn't remove previous deprecation behaviors" do
    behavior = ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:silence]
    ActiveSupport::Deprecation.behavior = behavior

    expect(ActiveSupport::Deprecation.behavior).to(include(behavior))
  end
end
