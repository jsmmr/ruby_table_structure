# frozen_string_literal: true

module TableStructure
  module Schema
    module Column
      module Utils
        DEFAULT_SIZE = 1

        def self.calculate_size(values)
          return DEFAULT_SIZE unless values.is_a?(Array)

          values.empty? ? DEFAULT_SIZE : values.size
        end

        def self.optimize_values(values, size:)
          expected_size = size
          return values if expected_size == DEFAULT_SIZE && !values.is_a?(Array)

          values = [values].flatten
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
