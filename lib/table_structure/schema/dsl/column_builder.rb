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
            ::TableStructure::Utils::TypedProc.new(
              types: { header: !!header, body: !!body }.select { |_k, v| v }.keys,
              &block
            )
          nil
        end

        def column_builders
          @__column_builders__ ||= {}
        end

        alias column_converter column_builder
      end
    end
  end
end
