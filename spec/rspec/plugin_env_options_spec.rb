# frozen_string_literal: true

# This needs to be set before we require `spec_helper` to simulate setting an ENV when running a spec like:
# `DEPRECATION_BEHAVIOR="record" bundle exec rspec path/to/spec.rb`
ENV["DEPRECATION_BEHAVIOR"] = "record"

require "spec_helper"

RSpec.describe("DeprecationToolkit::RSpecPlugin ENV options") do
  it "should set the behavior to `Record` when ENV variable is set" do
    expect(DeprecationToolkit::Configuration.behavior).to(eq(DeprecationToolkit::Behaviors::Record))
  end
end
