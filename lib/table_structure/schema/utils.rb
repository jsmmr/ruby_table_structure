# frozen_string_literal: true

module TableStructure
  module Schema
    module Utils
      def self.evaluate_callable(val, *params)
        val.respond_to?(:call) ? val.call(*params) : val
      end

      def self.schema_class?(val)
        val.is_a?(Class) &&
          val.included_modules.include?(::TableStructure::Schema)
      end

      def self.schema_instance?(val)
        val.is_a?(::TableStructure::Schema)
      end
    end
  end
end
