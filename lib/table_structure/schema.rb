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

    def initialize(
      name: self.class.name,
      context: nil,
      name_prefix: nil,
      name_suffix: nil,
      key_prefix: nil,
      key_suffix: nil,
      nil_definitions_ignored: false,
      **deprecated_options
    )
      unless deprecated_options.empty?
        caller_location = caller_locations(1, 1)
        deprecated_options.keys.each do |k|
          warn "[TableStructure] Specify #{k} option on the writer or the iterator. #{caller_location}"
        end
      end

      column_definitions = [].concat(self.class.column_definitions)
      context_builders = {}.merge!(self.class.context_builders)
      column_converters = {}.merge!(self.class.column_converters)
      result_builders = {}.merge!(self.class.result_builders)
      options = {
        name_prefix: name_prefix,
        name_suffix: name_suffix,
        key_prefix: key_prefix,
        key_suffix: key_suffix,
        nil_definitions_ignored: nil_definitions_ignored
      }.merge!(self.class.options).merge!(deprecated_options)

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

    def create_table(**options, &block)
      @table_structure_schema_definition_.create_table(**options, &block)
    end
  end
end
