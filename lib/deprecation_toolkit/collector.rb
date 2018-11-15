# frozen_string_literal: true

require "active_support/core_ext/class/attribute"

module DeprecationToolkit
  class Collector
    include Comparable
    extend ReadWriteHelper

    class_attribute :deprecations
    self.deprecations = []
    delegate :size, to: :deprecations

    class << self
      def collect(message)
        deprecations << message
      end

      def load(test)
        new(read(test))
      end

      def reset!
        deprecations.clear
      end
    end

    def initialize(deprecations)
      self.deprecations = deprecations
    end

    def <=>(other)
      deprecations_without_stacktrace <=> other.deprecations_without_stacktrace
    end

    def deprecations_without_stacktrace
      deprecations.map do |deprecation|
        if ActiveSupport.gem_version.to_s < "5.0"
          deprecation.sub(/\W\s\(called from .*\)$/, "")
        else
          deprecation.sub(/ \(called from .*\)$/, "")
        end
      end
    end

    def -(other)
      difference = deprecations.dup
      current = deprecations_without_stacktrace
      other = other.deprecations_without_stacktrace

      other.each do |deprecation|
        index = current.index(deprecation)

        if index
          current.delete_at(index)
          difference.delete_at(index)
        end
      end

      difference
    end
  end
end
