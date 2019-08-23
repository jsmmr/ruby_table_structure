# frozen_string_literal: true

module TableStructure
  module Schema
    module DSL
      module Option
        def option(name, value)
          options[name] = value
          nil
        end

        def options
          @table_structure_schema_options__ ||= {}
        end
      end
    end
  end
end
