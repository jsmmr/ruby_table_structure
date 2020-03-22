# frozen_string_literal: true

module TableStructure
  module Schema
    module DSL
      module ContextBuilder
        def context_builder(name, callable = nil, &block)
          if callable
            warn "[TableStructure] Use `block` instead of #{callable}."
          end

          block ||= callable

          context_builders[name] =
            ::TableStructure::Schema::Definition::ContextBuilder.new(
              &block
            )
          nil
        end

        def context_builders
          @__context_builders__ ||= {}
        end
      end
    end
  end
end
