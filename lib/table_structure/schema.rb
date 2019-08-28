# frozen_string_literal: true

module TableStructure
  module Schema
    def self.included(klass)
      klass.extend(DSL::ColumnConverter)
      klass.extend(DSL::ColumnDefinition)
      klass.extend(DSL::ContextBuilder)
      klass.extend(DSL::Option)
      klass.extend(DSL::ResultBuilder)
    end

    DEFAULT_OPTIONS = {
      result_type: :array,
      key_prefix: nil,
      key_suffix: nil
    }.freeze

    def initialize(context: nil, **options)
      column_definitions = self.class.column_definitions
      column_converters = self.class.column_converters
      result_builders = self.class.result_builders
      context = self.class.context_builders[:table].call(context)
      options = DEFAULT_OPTIONS.merge(self.class.options).merge(options)
      @table_structure_schema_table_ =
        Table.new(
          column_definitions,
          column_converters,
          result_builders,
          context,
          options
        )
    end

    def header(context: nil)
      context = self.class.context_builders[:header].call(context)
      @table_structure_schema_table_.header_values(context)
    end

    def row(context: nil)
      context = self.class.context_builders[:row].call(context)
      @table_structure_schema_table_.row_values(context)
    end

    def column_converters
      @table_structure_schema_table_.column_converters
    end

    def result_builders
      @table_structure_schema_table_.result_builders
    end
  end
end
