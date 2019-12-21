# frozen_string_literal: true

module TableStructure
  module Schema
    module DSL
      module ColumnDefinition
        def column(definition)
          column_definitions << definition
          nil
        end

        def columns(definition)
          column(definition)
        end

        def column_definitions
          @__column_definitions__ ||= []
        end
      end
    end
  end
end
