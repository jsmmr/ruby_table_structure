module TableStructure
  module Schema
    module DSL
      module ColumnConverter
        def column_converter(name, callable)
          column_converters[name] = callable
          return
        end

        def column_converters
          @table_structure_schema_column_converters__ ||= {}
        end
      end
    end
  end
end
