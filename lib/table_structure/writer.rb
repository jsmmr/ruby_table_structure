# frozen_string_literal: true

module TableStructure
  class Writer
    def initialize(
      schema,
      header: { context: nil },
      method: :<<,
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

      @schema = schema
      @options = {
        header: header,
        method: method,
        row_type: row_type
      }
    end

    def write(
      items,
      to:,
      method: @options[:method],
      **deprecated_options,
      &block
    )
      header = @options[:header]
      row_type = @options[:row_type]

      if deprecated_options.key?(:header)
        header = deprecated_options[:header]
        warn '[TableStructure] Use :header option on initialize method.'
      end

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

      if deprecated_options.key?(:row_type)
        row_type = deprecated_options[:row_type]
        warn '[TableStructure] Use :row_type option on initialize method.'
      end

      if deprecated_options.key?(:result_type)
        warn '[TableStructure] `:result_type` option has been deprecated. Use `:row_type` option instead.'
        row_type = deprecated_options[:result_type]
      end

      output = Output.new(to, method: method)

      Iterator
        .new(@schema, header: header, row_type: row_type)
        .iterate(items, &block)
        .each { |row| output.write(row) }

      nil
    end

    private

    class Output
      def initialize(output, method: :<<)
        @output = output
        @method = method
      end

      def write(values)
        @output.send(@method, values)
      end
    end
  end
end
