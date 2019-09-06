# frozen_string_literal: true

module TableStructure
  module Schema
    class Table
      attr_reader :column_converters, :result_builders

      def initialize(
        columns,
        context_builders,
        column_converters,
        result_builders,
        context,
        options
      )
        @columns = columns
        @header_context_builder = context_builders[:header]
        @row_context_builder = context_builders[:row]
        @column_converters = column_converters
        @result_builders = result_builders
        @context = context
        @options = options
      end

      def header(context: nil)
        if @header_context_builder
          context = @header_context_builder.call(context)
        end
        values(:name, context)
      end

      def row(context: nil)
        context = @row_context_builder.call(context) if @row_context_builder
        values(:value, context)
      end

      private

      def keys
        @keys ||= obtain_keys
      end

      def obtain_keys
        keys = @columns.map(&:keys).flatten
        has_key_options? ? decorate_keys(keys) : keys
      end

      def has_key_options?
        @options[:key_prefix] || @options[:key_suffix]
      end

      def decorate_keys(keys)
        keys.map do |key|
          next key unless key

          decorated_key = "#{@options[:key_prefix]}#{key}#{@options[:key_suffix]}"
          decorated_key = decorated_key.to_sym if key.is_a?(Symbol)
          decorated_key
        end
      end

      def size
        @size ||= @columns.map(&:size).reduce(0) { |memo, size| memo + size }
      end

      def values(method, context)
        columns =
          @columns
          .map { |column| column.send(method, context, @context) }
          .flatten
          .map do |val|
            @column_converters.reduce(val) do |val, (_, column_converter)|
              column_converter.call(val, context, @context)
            end
          end

        @result_builders
          .reduce(columns) do |columns, (_, result_builder)|
            result_builder.call(columns, keys, context, @context)
          end
      end
    end
  end
end
