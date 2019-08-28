# frozen_string_literal: true

module TableStructure
  module Schema
    class Table
      attr_reader :columns, :column_converters, :result_builders

      def initialize(column_definitions, column_converters, result_builders, context, options)
        @columns = build_columns(column_definitions, context, options)
        @column_converters = default_column_converters.merge(column_converters)
        @result_builders = default_result_builders(options).merge(result_builders)
        @context = context
      end

      def header_values(context)
        values(:name, context)
      end

      def row_values(context)
        values(:value, context)
      end

      private

      def build_columns(definitions, context, options)
        Definition
          .new(definitions, options)
          .compile(context)
          .map { |attrs| Column.new(attrs) }
      end

      def default_column_converters
        {}
      end

      def default_result_builders(options)
        result_builders = {}
        if options[:result_type] == :hash
          result_builders[:to_h] = ->(array, *) { (@keys ||= keys).zip(array).to_h }
        end
        result_builders
      end

      def keys
        @columns.map(&:key).flatten
      end

      def values(method, context)
        columns = @columns
                  .map { |column| column.send(method, context, @context) }
                  .flatten
                  .map { |val| reduce_callables(@column_converters, val, context) }
        reduce_callables(@result_builders, columns, context)
      end

      def reduce_callables(callables, val, context)
        callables.reduce(val) { |val, (_, callable)| callable.call(val, context, @context) }
      end
    end
  end
end
