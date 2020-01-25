# frozen_string_literal: true

module TableStructure
  module Schema
    module DSL
      module RowBuilder
        def row_builder(
          name,
          callable,
          enabled_row_types: %i[array hash]
        )
          row_builders[name] =
            ::TableStructure::Schema::Definition::RowBuilder.new(
              callable,
              enabled_row_types: enabled_row_types
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
