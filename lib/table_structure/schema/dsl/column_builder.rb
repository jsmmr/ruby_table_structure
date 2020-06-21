# frozen_string_literal: true

module TableStructure
  module Schema
    module DSL
      module ColumnBuilder
        def column_builder(
          name,
          header: true,
          body: true,
          &block
        )
          column_builders[name] =
            ::TableStructure::Schema::Definition::ColumnBuilder.new(
              header: header,
              body: body,
              &block
            )
          nil
        end

        def column_builders
          @__column_builders__ ||= {}
        end

        alias_method :column_converter, :column_builder
      end
    end
  end
end
