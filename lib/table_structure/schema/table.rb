# frozen_string_literal: true

module TableStructure
  module Schema
    class Table
      DEFAULT_OPTIONS = {
        result_type: :array
      }.freeze

      def initialize(
        columns,
        context,
        options
      )
        @columns = columns
        @context = context
        @options = DEFAULT_OPTIONS.merge(options)
      end

      def header(context: nil)
        values(:name, context)
      end

      def row(context: nil)
        values(:value, context)
      end

      def rows(items)
        Enumerator.new do |y|
          items.each { |item| y << row(context: item) }
        end
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
