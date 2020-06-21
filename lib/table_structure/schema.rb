# frozen_string_literal: true

module TableStructure
  module Schema
    def self.included(klass)
      klass.extend(DSL::ColumnBuilder)
      klass.extend(DSL::ColumnDefinition)
      klass.extend(DSL::ContextBuilder)
      klass.extend(DSL::RowBuilder)
      klass.extend(ClassMethods)
    end

    def self.create_class(&block)
      raise ::TableStructure::Error, 'No block given.' unless block

      schema_module = self
      Class.new do
        include schema_module
        class_eval(&block)
      end
    end

    attr_reader :columns,
                :context_builders,
                :column_builders,
                :key_converter,
                :row_builders,
                :context

    def initialize(
      name: self.class.name,
      context: nil,
      name_prefix: nil,
      name_suffix: nil,
      key_prefix: nil,
      key_suffix: nil,
      nil_definitions_ignored: false,
      &block
    )
      schema_classes = [self.class]

      schema_classes << ::TableStructure::Schema.create_class(&block) if block_given?

      @context_builders =
        schema_classes
        .map(&:context_builders)
        .reduce({}, &:merge!)

      table_context_builder = @context_builders.delete(:table)

      @context = table_context_builder ? table_context_builder.call(context) : context

      @column_builders =
        schema_classes
        .map(&:column_builders)
        .reduce({}, &:merge!)
        .merge(
          ColumnBuilder.create_optional_builders(
            name_prefix: name_prefix,
            name_suffix: name_suffix
          )
        )

      @key_converter = KeyConverter.new(
        prefix: key_prefix,
        suffix: key_suffix
      )

      @row_builders =
        RowBuilder.prepend_default_builders(
          schema_classes
            .map(&:row_builders)
            .reduce({}, &:merge!)
        )

      @columns =
        Definition::Columns::Compiler
        .new(
          name,
          schema_classes.map(&:column_definitions).reduce([], &:concat),
          { nil_definitions_ignored: nil_definitions_ignored }
        )
        .compile(@context)
    end

    def contain_callable?(attribute)
      @columns.any? { |column| column.contain_callable?(attribute) }
    end
  end
end
