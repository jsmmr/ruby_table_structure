# frozen_string_literal: true

module TableStructure
  module Schema
    module Column
      class Attrs
        attr_reader :keys, :size

        def initialize(definition, options)
          @name = definition[:name]
          @keys = optimize_size([definition[:key]].flatten, definition[:size])
          @value = definition[:value]
          @size = definition[:size]
          @options = options
        end

        def name(header_context, table_context)
          name = Utils.evaluate_callable(@name, header_context, table_context)
          optimize_size(name, @size)
        end

        def value(row_context, table_context)
          value = Utils.evaluate_callable(@value, row_context, table_context)
          optimize_size(value, @size)
        end

        private

        def optimize_size(value, expected_size)
          return value if expected_size == 1 && !value.is_a?(Array)

          values = [value].flatten
          actual_size = values.size
          if actual_size > expected_size
            values[0, expected_size]
          elsif actual_size < expected_size
            [].concat(values).fill(nil, actual_size, (expected_size - actual_size))
          else
            values
          end
        end
      end
    end
  end
end
