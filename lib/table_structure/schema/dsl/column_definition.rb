module TableStructure
  module Schema
    module DSL
      module ColumnDefinition
        def column(definition)
          column_definitions << definition
          return
        end

        def columns(definition)
          column(definition)
        end

        def column_definitions
          @table_structure_schema_column_definitions__ ||= []
        end
      end
    end
  end
end
