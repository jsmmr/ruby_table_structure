# frozen_string_literal: true

module TableStructure
  class Iterator
    def initialize(
      schema,
      header: { context: nil },
      row_type: :array
    )
      @schema = schema
      @options = {
        header: header,
        row_type: row_type
      }
    end

    def iterate(items, &block)
      unless items.respond_to?(:each)
        raise ::TableStructure::Error, "Must be enumerable. #{items}"
      end

      enum =
        Table::Iterator
        .new(
          Table.new(@schema, row_type: @options[:row_type]),
          header: @options[:header]
        )
        .iterate(items)

      if block_given?
        enum =
          enum
          .lazy
          .map { |row| block.call(row) }
      end

      enum
    end
  end
end
