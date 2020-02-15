# frozen_string_literal: true

module TableStructure
  class Writer
    def initialize(
      schema,
      header_omitted: false,
      header_context: nil,
      method: :<<,
      row_type: :array,
      **deprecated_options
    )
      if deprecated_options.key?(:result_type)
        warn '[TableStructure] `:result_type` option has been deprecated. Use `:row_type` option instead.'
        row_type = deprecated_options[:result_type]
      end

      @schema = schema
      @options = {
        header_omitted: header_omitted,
        header_context: header_context,
        method: method,
        row_type: row_type
      }
    end

    def write(
      items,
      to:,
      method: @options[:method],
      header_omitted: @options[:header_omitted],
      header_context: @options[:header_context],
      row_type: @options[:row_type],
      **deprecated_options,
      &block
    )
      if deprecated_options.key?(:result_type)
        warn '[TableStructure] `:result_type` option has been deprecated. Use `:row_type` option instead.'
        row_type = deprecated_options[:result_type]
      end

      items = enumerize(items)

      header_options =
        if header_omitted
          false
        else
          { context: header_context }
        end

      @schema.create_table(row_type: row_type) do |table|
        output = Output.new(to, method: method)

        enum =
          Table::Iterator
          .new(
            table,
            header: header_options
          )
          .iterate(items)

        if block_given?
          enum =
            enum
            .lazy
            .map { |row| block.call(row) }
        end

        enum.each { |row| output.write(row) }
      end
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

    def enumerize(items)
      if items.respond_to?(:each)
        items
      elsif items.respond_to?(:call)
        warn "[TableStructure] Use `Enumerator` to wrap items instead of `lambda`. The use of `lambda` has been deprecated. #{items}"
        Enumerator.new { |y| items.call(y) }
      else
        raise ::TableStructure::Error, "Must be enumerable. #{items}"
      end
    end
  end
end
