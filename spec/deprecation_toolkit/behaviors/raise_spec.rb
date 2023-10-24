# frozen_string_literal: true

require "spec_helper"

RSpec.describe(DeprecationToolkit::Behaviors::Raise) do
  before do
    @previous_configuration = DeprecationToolkit::Configuration.behavior
    DeprecationToolkit::Configuration.behavior = DeprecationToolkit::Behaviors::Raise
  end

  after do
    DeprecationToolkit::Configuration.behavior = @previous_configuration
  end

  it ".trigger raises an DeprecationIntroduced error when deprecations are introduced" do |example|
    expect do
      ActiveSupport::Deprecation.new.warn("Foo")
      ActiveSupport::Deprecation.new.warn("Bar")

      DeprecationToolkit::TestTriggerer.trigger_deprecation_toolkit_behavior(example)
    end.to(raise_error(DeprecationToolkit::Behaviors::DeprecationIntroduced))
  end

  it ".trigger raises a DeprecationRemoved error when deprecations are removed" do |example|
    expect do
      ActiveSupport::Deprecation.new.warn("Foo")

      DeprecationToolkit::TestTriggerer.trigger_deprecation_toolkit_behavior(example)
    end.to(raise_error(DeprecationToolkit::Behaviors::DeprecationRemoved))
  end

  it ".trigger raises a DeprecationRemoved when mismatched and less than expected" do |example|
    expect do
      ActiveSupport::Deprecation.new.warn("C")

      DeprecationToolkit::TestTriggerer.trigger_deprecation_toolkit_behavior(example)
    end.to(raise_error(DeprecationToolkit::Behaviors::DeprecationRemoved))
  end

  it ".trigger raises a DeprecationMismatch when same number of deprecations are triggered with mismatches" do |example|
    expect do
      ActiveSupport::Deprecation.new.warn("A")

      DeprecationToolkit::TestTriggerer.trigger_deprecation_toolkit_behavior(example)
    end.to(raise_error(DeprecationToolkit::Behaviors::DeprecationMismatch))
  end

  it ".trigger does not raise when deprecations are triggered but were already recorded" do |example|
    expect do
      ActiveSupport::Deprecation.new.warn("Foo")
      ActiveSupport::Deprecation.new.warn("Bar")

      DeprecationToolkit::TestTriggerer.trigger_deprecation_toolkit_behavior(example)
    end.not_to(raise_error)
  end

  it ".trigger does not raise when deprecations are allowed with Regex" do |example|
    @old_allowed_deprecations = DeprecationToolkit::Configuration.allowed_deprecations
    DeprecationToolkit::Configuration.allowed_deprecations = [/John Doe/]

    begin
      ActiveSupport::Deprecation.new.warn("John Doe")
      expect do
        DeprecationToolkit::TestTriggerer.trigger_deprecation_toolkit_behavior(example)
      end.not_to(raise_error)
    ensure
      DeprecationToolkit::Configuration.allowed_deprecations = @old_allowed_deprecations
    end
  end

  it ".trigger does not raise when deprecations are allowed with Procs" do |example|
    class_eval <<-RUBY, "my_file.rb", 1337
      def deprecation_caller
        deprecation_callee
      end

      def deprecation_callee
        ActiveSupport::Deprecation.new.warn("John Doe")
      end
    RUBY

    old_allowed_deprecations = DeprecationToolkit::Configuration.allowed_deprecations
    DeprecationToolkit::Configuration.allowed_deprecations = [
      ->(_, stack) { stack.first.to_s =~ /my_file\.rb/ },
    ]

    begin
      deprecation_caller
      expect do
        DeprecationToolkit::TestTriggerer.trigger_deprecation_toolkit_behavior(example)
      end.not_to(raise_error)
    ensure
      DeprecationToolkit::Configuration.allowed_deprecations = old_allowed_deprecations
    end
  end
end
