# frozen_string_literal: true

module TableStructure
  module Schema
    class Table
      RESULT_BUILDERS = {
        hash: ->(values, keys, *) { keys.zip(values).to_h }
      }.freeze

      attr_reader :columns, :column_converters, :result_builders, :options

      def initialize(name, column_definitions, column_converters, result_builders, context, options)
        @name = name
        @columns = build_columns(name, column_definitions, context, options)
        @column_converters = column_converters
        @result_builders = result_builders
        @context = context
        @options = options
      end

      def header_values(context, result_type = nil) # TODO
        values(:name, result_type, context)
      end

      def row_values(context, result_type = nil) # TODO
        values(:value, result_type, context)
      end

      def keys
        @keys ||= @columns.map(&:key).flatten
      end

      def size
        @size ||= @columns.map(&:size).reduce(0) { |memo, size| memo + size }
      end

      private

      def build_columns(name, definitions, context, options)
        indexer = Indexer.new
        Definition
          .new(name, definitions, options)
          .compile(context)
          .map do |definition|
            Column.create(definition, indexer, options)
          end
      end

      def values(method, result_type, context)
        columns =
          @columns
          .map { |column| column.send(method, context, @context) }
          .flatten
          .map do |val|
            @column_converters.reduce(val) do |val, (_, column_converter)|
              column_converter.call(val, context, @context)
            end
          end

        RESULT_BUILDERS
          .select { |k, _v| k == result_type }
          .merge(@result_builders)
          .reduce(columns) do |columns, (_, result_builder)|
            result_builder.call(columns, keys, context, @context)
          end
      end
    end
  end
end
