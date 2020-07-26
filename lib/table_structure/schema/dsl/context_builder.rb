# frozen_string_literal: true

module TableStructure
  module Schema
    module DSL
      module ContextBuilder
        # TODO: Change definition style
        def context_builder(name, &block)
          context_builders[name] = block
          nil
        end

        def context_builders
          @__context_builders__ ||= {}
        end
      end
    end
  end
end
