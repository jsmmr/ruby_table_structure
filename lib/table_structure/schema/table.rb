# frozen_string_literal: true

module TableStructure
  module Schema
    class Table
      # TODO: Remove following `attr_reader`.
      attr_reader :header_column_converters, :row_column_converters, :result_builders

      def initialize(
        columns,
        header_context_builder,
        row_context_builder,
        header_column_converters,
        row_column_converters,
        result_builders,
        context,
        options
      )
        @columns = columns
        @header_column_converters = header_column_converters
        @row_column_converters = row_column_converters
        @result_builders = result_builders
        @context = context
        @options = options

        if header_context_builder || row_context_builder
          singleton_class.include ContextBuilder.new(
            [
              { method: :header, callable: header_context_builder },
              { method: :row, callable: row_context_builder }
            ]
          )
        end

        if !header_column_converters.empty? || !row_column_converters.empty?
          singleton_class.include ColumnConverter.new(
            [
              { method: :header, callables: header_column_converters },
              { method: :row, callables: row_column_converters }
            ],
            context: context
          )
        end

        unless result_builders.empty?
          singleton_class.include ResultBuilder.new(
            [
              { method: :header, callables: result_builders },
              { method: :row, callables: result_builders }
            ],
            keys: keys,
            context: context
          )
        end
      end

      def header(context: nil)
        values(:name, context)
      end

      def row(context: nil)
        values(:value, context)
      end

      private

      def keys
        @keys ||= begin
          keys = @columns.map(&:keys).flatten
          KeyDecorator.new(
            prefix: @options[:key_prefix],
            suffix: @options[:key_suffix]
          ).decorate(keys)
        end
      end

      def size
        @size ||= @columns.map(&:size).reduce(0, &:+)
      end

      def values(method, context)
        @columns
          .map { |column| column.send(method, context, @context) }
          .flatten
      end
    end
  end
end
