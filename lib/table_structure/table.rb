# frozen_string_literal: true

module TableStructure
  class Table
    def initialize(schema, row_type: :array)
      @columns = schema.columns
      @context = schema.context
      @key_converter = schema.key_converter

      ContextBuilder.create_module(
        schema.context_builders,
        apply_to_name: schema.contain_callable?(:name),
        apply_to_value: schema.contain_callable?(:value),
        context: schema.context
      ) { |mod| self.extend mod }

      ColumnConverter.create_module(
        schema.column_converters,
        context: schema.context
      ) { |mod| self.extend mod }

      RowBuilder.create_module(
        schema.row_builders,
        row_type: row_type,
        keys: keys,
        context: schema.context
      ) { |mod| self.extend mod }

      yield self if block_given?
    end

    def header(context: nil)
      row_values(:names, context)
    end

    def body(items)
      Enumerator.new do |y|
        items.each { |item| y << data(context: item) }
      end
    end

    def rows(items)
      warn '[TableStructure] `TableStructure::Table#rows(items)` has been deprecated. Use `TableStructure::Table#body(items)` instead.'
      body(items)
    end

    def row(context: nil)
      warn '[TableStructure] `TableStructure::Table#row(context: ...)` has been deprecated. Use `TableStructure::Table#body(items)` instead.'
      data(context: context)
    end

    private

    def data(context: nil)
      row_values(:values, context)
    end

    def keys
      @keys ||= @key_converter.convert(@columns.map(&:keys).flatten)
    end

    def size
      @size ||= @columns.map(&:size).reduce(0, &:+)
    end

    def row_values(method, context)
      @columns
        .map { |column| column.send(method, context, @context) }
        .flatten
    end
  end
end
