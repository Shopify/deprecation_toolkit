# frozen_string_literal: true

RSpec.shared_examples("shared examples") do |deprecation_path|
  context "nested shared context" do
    it "uses the spec filename to record the deprecation" do |example|
      ActiveSupport::Deprecation.warn("Foo")

      DeprecationToolkit::TestTriggerer.trigger_deprecation_toolkit_behavior(example)

      recorded = YAML.load_file("#{@deprecation_path}/#{deprecation_path}")
        .fetch("test_" + example.full_description.underscore.squish.tr(" ", "_"))

      expect(recorded).to(eq(["DEPRECATION WARNING: Foo"]))
    end
  end
end
