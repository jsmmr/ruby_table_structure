# frozen_string_literal: true

module TableStructure
  class Writer
    def initialize(
      schema,
      header: { context: nil, step: nil },
      method: :<<,
      row_type: :array
    )
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
      &block
    )
      output = Output.new(to, method: method)

      Iterator
        .new(
          @schema,
          header: @options[:header],
          row_type: @options[:row_type]
        )
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
