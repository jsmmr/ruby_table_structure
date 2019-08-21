# frozen_string_literal: true

module TableStructure
  class Iterator
    def initialize(schema_or_writer, **options)
      case
      when schema_or_writer.is_a?(Schema)
        schema = schema_or_writer
        @writer = Writer.new(schema, options)
      when schema_or_writer.is_a?(Writer)
        @writer = schema_or_writer
      else
        raise ::TableStructure::Error.new('First argument must be either Schema or Writer.')
      end
    end

    def iterate(items)
      Enumerator.new { |y| @writer.write(items, to: y) }
    end
  end
end
