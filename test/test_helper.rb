# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "deprecation_toolkit"

require "minitest/autorun"
require "active_support/all"

ActiveSupport::Deprecation.behavior = :silence
