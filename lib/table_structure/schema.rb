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
      name_prefix: nil,
      name_suffix: nil,
      key_prefix: nil,
      key_suffix: nil,
      nil_definitions_ignored: false
    }.freeze

    def initialize(context: nil, name: self.class.name, **options)
      column_definitions = [].concat(self.class.column_definitions)
      context_builders = {}.merge!(self.class.context_builders)
      column_converters = {}.merge!(self.class.column_converters)
      result_builders = {}.merge!(self.class.result_builders)
      options = DEFAULT_OPTIONS.merge(self.class.options).merge(options)
      @table_structure_schema_definition_ =
        Definition.new(
          name,
          column_definitions,
          context_builders,
          column_converters,
          result_builders,
          context,
          options
        )
    end

    def create_table(result_type: :array, **options)
      options = @table_structure_schema_definition_.options.merge(options)
      @table_structure_schema_definition_.create_table(result_type: result_type, **options)
    end
  end
end
