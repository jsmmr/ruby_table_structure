# frozen_string_literal: true

module TableStructure
  module Schema
    module DSL
      module RowBuilder
        def row_builder(
          name,
          enabled_row_types: %i[array hash],
          &block
        )
          row_builders[name] =
            ::TableStructure::Utils::TypedProc.new(
              types: enabled_row_types,
              &block
            )
          nil
        end

        def row_builders
          @__row_builders__ ||= {}
        end
      end
    end
  end
end
