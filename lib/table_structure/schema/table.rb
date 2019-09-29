# frozen_string_literal: true

module TableStructure
  module Schema
    class Table
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

        if header_context_builder
          singleton_class.include ContextBuilder.new(:header, header_context_builder)
        end

        if row_context_builder
          singleton_class.include ContextBuilder.new(:row, row_context_builder)
        end
      end

      def header(context: nil)
        values(:name, context, @header_column_converters)
      end

      def row(context: nil)
        values(:value, context, @row_column_converters)
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
        @size ||= @columns.map(&:size).reduce(0) { |memo, size| memo + size }
      end

      def values(method, context, converters)
        values =
          @columns
          .map { |column| column.send(method, context, @context) }
          .flatten

        unless converters.empty?
          values = values.map do |val|
            converters.reduce(val) do |val, (_, converter)|
              converter.call(val, context, @context)
            end
          end
        end

        @result_builders
          .reduce(values) do |vals, (_, result_builder)|
            result_builder.call(vals, keys, context, @context)
          end
      end
    end
  end
end
