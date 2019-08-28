# frozen_string_literal: true

module TableStructure
  module Schema
    module Utils
      def self.evaluate_callable(val, *params)
        val.respond_to?(:call) ? val.call(*params) : val
      end

      def self.concat_key(key, prefix, suffix)
        case key
        when Symbol
          "#{prefix}#{key}#{suffix}".to_sym
        else
          "#{prefix}#{key}#{suffix}"
        end
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
