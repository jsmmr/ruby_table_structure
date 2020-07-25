# frozen_string_literal: true

module TableStructure
  module Schema
    module Columns
      class Attributes
        attr_reader :keys, :size

        def initialize(name:, key:, value:, size:)
          @name_callable = Utils.callable?(name)
          @name = @name_callable ? name : proc { name }
          @keys = optimize_size([key].flatten, size)
          @value_callable = Utils.callable?(value)
          @value = @value_callable ? value : proc { value }
          @size = size
        end

        def names(context, table_context)
          names = @name.call(context, table_context)
          optimize_size(names, @size)
        end

        def values(context, table_context)
          values = @value.call(context, table_context)
          optimize_size(values, @size)
        end

        def name_callable?
          @name_callable
        end

        def value_callable?
          @value_callable
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
