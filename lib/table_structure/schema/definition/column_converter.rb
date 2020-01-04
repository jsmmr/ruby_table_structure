# frozen_string_literal: true

module TableStructure
  module Schema
    module Definition
      class ColumnConverter
        extend Forwardable

        def_delegator :@callable, :call

        def initialize(
          callable,
          header: true,
          row: true
        )
          @callable = callable
          @applicable_to_header = header
          @applicable_to_row = row
        end

        def applicable_to_header?
          !!@applicable_to_header
        end

        def applicable_to_row?
          !!@applicable_to_row
        end
      end
    end
  end
end
