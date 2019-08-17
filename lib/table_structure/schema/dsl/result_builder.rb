# frozen_string_literal: true

module TableStructure
  module Schema
    module DSL
      module ResultBuilder
        def result_builder(name, callable)
          result_builders[name] = callable
          nil
        end

        def result_builders
          @table_structure_schema_result_builders__ ||= {}
        end
      end
    end
  end
end
