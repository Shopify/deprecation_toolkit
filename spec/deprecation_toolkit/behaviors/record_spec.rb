# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

RSpec.describe(DeprecationToolkit::Behaviors::Record) do
  before do
    @previous_deprecation_path = DeprecationToolkit::Configuration.deprecation_path
    @deprecation_path = Dir.mktmpdir
    @previous_behavior = DeprecationToolkit::Configuration.behavior
    DeprecationToolkit::Configuration.behavior = DeprecationToolkit::Behaviors::Record
    DeprecationToolkit::Configuration.deprecation_path = @deprecation_path
    DeprecationToolkit::Configuration.project_root = '/Users/snehasomwanshi/dev/freeagent'
  end

  after do
    DeprecationToolkit::Configuration.behavior = @previous_behavior
    DeprecationToolkit::Configuration.deprecation_path = @previous_deprecation_path
    FileUtils.rm_rf(@deprecation_path)
  end

  it '.trigger should record deprecations' do |example|
    expect_deprecations_recorded("Foo", "Bar", example) do
      ActiveSupport::Deprecation.warn("Foo")
      ActiveSupport::Deprecation.warn("Bar")

      DeprecationToolkit::TestTriggerer.trigger_deprecation_toolkit_behavior(example)
    end
  end

  it '.trigger should remove the rails app path from deprecation warning' do |example|
    real_warning =  "DEPRECATION WARNING: /Users/snehasomwanshi/dev/freeagent/app/models/payroll/rti_submission.rb:20: warning: Passing the keyword argument as the last hash parameter is deprecated" \
                    " /Users/snehasomwanshi/dev/freeagent/compartments/base_models/app/models/company.rb:120: warning: The called method `set_history_for' is defined here"
    recorded_warning = "DEPRECATION WARNING: app/models/payroll/rti_submission.rb:20: warning: Passing the keyword argument as the last hash parameter is deprecated" \
                       " compartments/base_models/app/models/company.rb:120: warning: The called method `set_history_for' is defined here"
    expect_deprecations_recorded(recorded_warning, example) do
      ActiveSupport::Deprecation.warn(real_warning)

      DeprecationToolkit::TestTriggerer.trigger_deprecation_toolkit_behavior(example)
    end
  end

  it ".trigger re-record an existing deprecation file" do |example|
    expect_deprecations_recorded("Foo", "Bar", example) do
      ActiveSupport::Deprecation.warn("Foo")
      ActiveSupport::Deprecation.warn("Bar")

      DeprecationToolkit::TestTriggerer.trigger_deprecation_toolkit_behavior(example)
    end

    expect_deprecations_recorded("Foo", example) do
      ActiveSupport::Deprecation.warn("Foo")

      DeprecationToolkit::TestTriggerer.trigger_deprecation_toolkit_behavior(example)
    end
  end

  it ".trigger removes the deprecation file when all deprecations were removed" do |example|
    expect_deprecations_recorded("Foo", example) do
      ActiveSupport::Deprecation.warn("Foo")

      DeprecationToolkit::TestTriggerer.trigger_deprecation_toolkit_behavior(example)
    end

    expect do
      expect_deprecations_recorded("Foo", example) do
        DeprecationToolkit::TestTriggerer.trigger_deprecation_toolkit_behavior(example)
      end
    end.to(raise_error(Errno::ENOENT))
  end

  private

  def expect_deprecations_recorded(*deprecation_triggered, example)
    yield

    recorded = YAML.load_file(
      "#{@deprecation_path}/deprecation_toolkit/behaviors/record.yml"
    ).fetch("test_" + example.full_description.underscore.squish.tr(" ", "_"))
    triggered = deprecation_triggered.map { |msg| "DEPRECATION WARNING: #{msg}" }

    expect(recorded).to(eq(triggered))
  end
end
