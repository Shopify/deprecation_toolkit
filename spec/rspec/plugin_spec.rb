# frozen_string_literal: true

require "spec_helper"

RSpec.describe(DeprecationToolkit::RSpecPlugin) do
  if ActiveSupport.gem_version < Gem::Version.new("7.1.0")
    def with_rails_70_app
      deprecators_before = Rails.application.method(:deprecators)
      Rails.application.singleton_class.undef_method(:deprecators)
      yield
    ensure
      Rails.application.singleton_class.define_method(:deprecators, &deprecators_before)
    end

    it "should add `notify` behavior to the deprecations behavior list" do
      with_rails_70_app do
        behavior = ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:notify]

        DeprecationToolkit::RSpecPlugin.before_suite
        expect(ActiveSupport::Deprecation.behavior).to(include(behavior))
      end
    end

    it "doesn't remove previous deprecation behaviors" do
      with_rails_70_app do
        behavior = ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:silence]

        DeprecationToolkit::RSpecPlugin.before_suite
        ActiveSupport::Deprecation.behavior = behavior
        expect(ActiveSupport::Deprecation.behavior).to(include(behavior))
      end
    end
  end
end
