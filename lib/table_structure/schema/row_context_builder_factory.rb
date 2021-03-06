# frozen_string_literal: true

module TableStructure
  module Schema
    class RowContextBuilderFactory
      def initialize(schema, builders)
        @schema = schema
        @builders = builders
      end

      def create_header_builder
        return unless @schema.contain_name_callable?
        return unless @builders.key?(:header)

        proc { |context| @builders[:header].call(context) }
      end

      def create_data_builder
        return unless @schema.contain_value_callable?
        return unless @builders.key?(:row)

        proc { |context| @builders[:row].call(context) }
      end
    end
  end
end
