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
        values(:names, context)
      end

      def row(context: nil)
        values(:values, context)
      end

      def rows(items)
        Enumerator.new do |y|
          items.each { |item| y << row(context: item) }
        end
      end

      private

      def keys
        @keys ||= @keys_generator.generate(@columns.map(&:keys).flatten)
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
