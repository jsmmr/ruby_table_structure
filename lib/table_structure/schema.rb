# frozen_string_literal: true

module TableStructure
  module Schema
    def self.included(klass)
      klass.extend(DSL::ColumnConverter)
      klass.extend(DSL::ColumnDefinition)
      klass.extend(DSL::ContextBuilder)
      klass.extend(DSL::Option)
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
                :column_converters,
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
      **deprecated_options,
      &block
    )
      if deprecated_options.key?(:row_type)
        raise ::TableStructure::Error, 'Use :row_type option with Table, Writer or Iterator.'
      end

      if deprecated_options.key?(:result_type)
        raise ::TableStructure::Error, ':result_type option has been deprecated. Use :row_type option instead.'
      end

      options =
        [
          self.class.options,
          {
            name_prefix: name_prefix,
            name_suffix: name_suffix,
            key_prefix: key_prefix,
            key_suffix: key_suffix,
            nil_definitions_ignored: nil_definitions_ignored
          },
          deprecated_options
        ]
        .reduce({}, &:merge!)

      schema_classes = [self.class]

      if block_given?
        schema_classes << ::TableStructure::Schema.create_class(&block)
      end

      @context_builders =
        schema_classes
          .map(&:context_builders)
          .reduce({}, &:merge!)

      table_context_builder = @context_builders.delete(:table)

      @context = table_context_builder ? table_context_builder.call(context) : context

      @column_converters =
        schema_classes
          .map(&:column_converters)
          .reduce({}, &:merge!)
          .merge(
            ColumnConverter.create_optional_converters(
              name_prefix: options.delete(:name_prefix),
              name_suffix: options.delete(:name_suffix)
            )
          )

      @key_converter = KeyConverter.new(
        prefix: options.delete(:key_prefix),
        suffix: options.delete(:key_suffix)
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
          { nil_definitions_ignored: options.delete(:nil_definitions_ignored) }
        )
        .compile(@context)

      @options = options
    end

    def create_table(row_type: :array, **deprecated_options, &block)
      warn '[TableStructure] `TableStructure::Schema#create_table` has been deprecated. Use `TableStructure::Table.new` instead.'

      options = @options.merge(deprecated_options)

      if options.key?(:result_type)
        warn '[TableStructure] `:result_type` option has been deprecated. Use `:row_type` option instead.'
        options[:row_type] = options[:result_type]
      end

      ::TableStructure::Table.new(self, row_type: options[:row_type] || row_type, &block)
    end

    def contain_callable?(attribute)
      @columns.any? { |column| column.contain_callable?(attribute) }
    end
  end
end
