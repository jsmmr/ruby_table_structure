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
      raise ::TableStructure::Error, 'No block has been given.' unless block

      ::Class.new do
        include Schema
        class_eval(&block)
      end
    end

    Row = ::Struct.new(:keys, :values, :context)

    attr_reader :row_builders,
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
      schema_class = CompositeClass.new.compose(self.class)
      schema_class.compose(Schema.create_class(&block)) if block

      context_builders = schema_class.context_builders

      table_context_builder = context_builders.delete(:table)

      @context = table_context_builder ? table_context_builder.call(context) : context

      @row_context_builder_factory = RowContextBuilderFactory.new(self, context_builders)

      @column_builder_factory = ColumnBuilderFactory.new(
        schema_class.column_builders,
        context: @context,
        name_prefix: name_prefix,
        name_suffix: name_suffix
      )

      @keys_builder = KeysBuilder.new(
        prefix: key_prefix,
        suffix: key_suffix
      )

      @row_builders = schema_class.row_builders

      @columns =
        Definition::Columns::Compiler
        .new(
          name,
          schema_class.column_definitions,
          nil_definitions_ignored: nil_definitions_ignored
        )
        .compile(@context)
    end

    def columns_keys
      @columns_keys ||= @keys_builder.build(@columns.map(&:keys).flatten)
    end

    def columns_size
      @columns.map(&:size).reduce(0, &:+)
    end

    def contain_callable?(attribute)
      @columns.any? { |column| column.contain_callable?(attribute) }
    end

    def create_header_row_generator
      ::TableStructure::Utils::CompositeCallable.new.compose(
        @row_context_builder_factory.create_header_builder,
        proc do |context|
          values =
            @columns
            .map { |column| column.names(context, @context) }
            .flatten

          Row.new(columns_keys, values, context)
        end,
        @column_builder_factory.create_header_builder
      )
    end

    def create_data_row_generator
      ::TableStructure::Utils::CompositeCallable.new.compose(
        @row_context_builder_factory.create_data_builder,
        proc do |context|
          values =
            @columns
            .map { |column| column.values(context, @context) }
            .flatten

          Row.new(columns_keys, values, context)
        end,
        @column_builder_factory.create_data_builder
      )
    end
  end
end
