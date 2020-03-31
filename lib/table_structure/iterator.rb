# frozen_string_literal: true

module TableStructure
  class Iterator
    def initialize(
      schema,
      header: { context: nil },
      row_type: :array,
      **deprecated_options
    )
      if deprecated_options.key?(:header_omitted)
        header_omitted = deprecated_options[:header_omitted]
        warn "[TableStructure] `header_omitted: #{!!header_omitted}` option has been deprecated. Use `header: #{!header_omitted}` option instead."
        header = !header_omitted
      end

      if deprecated_options.key?(:header_context)
        header_context = deprecated_options[:header_context]
        warn '[TableStructure] `:header_context` option has been deprecated. Use `header: { context: ... }` option instead.'
        header = { context: header_context }
      end

      if deprecated_options.key?(:result_type)
        warn '[TableStructure] `:result_type` option has been deprecated. Use `:row_type` option instead.'
        row_type = deprecated_options[:result_type]
      end

      unless schema.is_a?(Schema)
        raise ::TableStructure::Error, "Must be use Schema. #{schema}"
      end

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
