# frozen_string_literal: true

module TableStructure
  module Schema
    module Definition
      class RowBuilder
        extend Forwardable

        def_delegator :@callable, :call

        def initialize(
          enabled_row_types: %i[array hash],
          &block
        )
          @enabled_row_types = [enabled_row_types].flatten
          @callable = block
        end

        def enabled?(row_type)
          @enabled_row_types.include?(row_type)
        end
      end
    end
  end
end
