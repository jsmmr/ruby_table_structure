# frozen_string_literal: true

module TableStructure
  module Schema
    module Definition
      class RowBuilder
        extend Forwardable

        def_delegator :@callable, :call

        def initialize(
          callable,
          enabled_row_types: %i[array hash]
        )
          @callable = callable
          @enabled_row_types = [enabled_row_types].flatten
        end

        def enabled?(row_type)
          @enabled_row_types.include?(row_type)
        end
      end
    end
  end
end
