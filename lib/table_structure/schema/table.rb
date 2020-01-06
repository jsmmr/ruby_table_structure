# frozen_string_literal: true

module TableStructure
  module Schema
    class Table
      def initialize(
        columns,
        context,
        keys_generator
      )
        @columns = columns
        @context = context
        @keys_generator = keys_generator
      end

      def header(context: nil)
        row_values(:names, context)
      end

      def row(context: nil)
        warn "[TableStructure] `TableStructure::Schema::Table#row(context:)` has been deprecated. Use `TableStructure::Schema::Table#body(items)` instead."
        data(context: context)
      end

      def body(items)
        Enumerator.new do |y|
          items.each { |item| y << data(context: item) }
        end
      end

      def rows(items)
        warn "[TableStructure] `TableStructure::Schema::Table#rows(items)` has been deprecated. Use `TableStructure::Schema::Table#body(items)` instead."
        body(items)
      end

      private

      def data(context: nil)
        row_values(:values, context)
      end

      def keys
        @keys ||= @keys_generator.generate(@columns.map(&:keys).flatten)
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
end
