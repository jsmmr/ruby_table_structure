# frozen_string_literal: true

module TableStructure
  class Iterator
    def initialize(schema_or_writer, **options)
      if schema_or_writer.is_a?(Schema)
        schema = schema_or_writer
        @writer = Writer.new(schema, **options)
      elsif schema_or_writer.is_a?(Writer)
        warn "[TableStructure] Pass Writer as an argument has been deprecated. Pass Schema instead. #{caller_locations(1, 1)}"
        @writer = schema_or_writer
      else
        raise ::TableStructure::Error, "Must be either Schema or Writer. #{schema_or_writer}"
      end
    end

    def iterate(items, **options, &block)
      # TODO: Change not to use Writer.
      Enumerator.new { |y| @writer.write(items, to: y, **options, &block) }
    end
  end
end
