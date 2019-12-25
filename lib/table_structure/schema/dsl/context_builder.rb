# frozen_string_literal: true

module TableStructure
  module Schema
    module DSL
      module ContextBuilder
        def context_builder(name, callable)
          context_builders[name] = callable
          nil
        end

        def context_builders
          @__context_builders__ ||= {}
        end
      end
    end
  end
end
