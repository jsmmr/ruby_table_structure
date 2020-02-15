# frozen_string_literal: true

module TableStructure
  module Schema
    module Columns
      class Attributes
        attr_reader :keys, :size

        def initialize(name:, key:, value:, size:)
          @name = name
          @keys = optimize_size([key].flatten, size)
          @value = value
          @size = size
        end

        def names(context, table_context)
          name = Utils.evaluate_callable(@name, context, table_context)
          optimize_size(name, @size)
        end

        def values(context, table_context)
          value = Utils.evaluate_callable(@value, context, table_context)
          optimize_size(value, @size)
        end

        def contain_callable?(attribute)
          val = instance_variable_get("@#{attribute}")
          Utils.callable?(val)
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