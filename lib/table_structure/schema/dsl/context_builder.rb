module TableStructure
  module Schema
    module DSL
      module ContextBuilder
        def context_builder(name, callable)
          context_builders[name] = callable
          return
        end

        def context_builders
          @table_structure_schema_context_builders__ ||= Hash.new(->(val) { val })
        end
      end
    end
  end
end
