# frozen_string_literal: true

module TableStructure
  module Schema
    module DSL
      module RowBuilder
        def row_builder(
          name,
          callable = nil,
          enabled_row_types: %i[array hash],
          &block
        )
          if callable
            warn "[TableStructure] Use `block` instead of #{callable}."
          end

          block ||= callable

          row_builders[name] =
            ::TableStructure::Schema::Definition::RowBuilder.new(
              enabled_row_types: enabled_row_types,
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
