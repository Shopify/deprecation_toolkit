# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "bundler"
gem "minitest"
gem "rake"
gem "rspec"
gem "rubocop-shopify"

if defined?(@activesupport_gem_requirement) && @activesupport_gem_requirement
  # causes Dependabot to ignore the next line
  activesupport = "activesupport"
  gem activesupport, @activesupport_gem_requirement
end
