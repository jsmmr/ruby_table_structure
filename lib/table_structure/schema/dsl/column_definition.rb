# frozen_string_literal: true

module TableStructure
  module Schema
    module DSL
      module ColumnDefinition
        def column(definition)
          unless definition.is_a?(Hash)
            warn "[TableStructure] Use `columns` instead of `column`.", uplevel: 1
          end
          column_definitions << definition
          nil
        end

        def columns(definition = nil, &block)
          if definition.is_a?(Hash)
            warn "[TableStructure] Use `column` instead of `columns`.", uplevel: 1
          end
          if Utils.callable?(definition)
            warn "[TableStructure] Use `block` instead of `lambda` or `proc`.", uplevel: 1
          end
          column_definitions << (block || definition)
          nil
        end

        def column_definitions
          @__column_definitions__ ||= []
        end
      end
    end
  end
end
