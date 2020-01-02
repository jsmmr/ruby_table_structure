# frozen_string_literal: true

module TableStructure
  module Schema
    module DSL
      module ResultBuilder
        def result_builder(
          name,
          callable,
          enabled_result_types: %i[array hash]
        )
          result_builders[name] =
            ::TableStructure::Schema::ResultBuilder.new(
              callable,
              enabled_result_types: enabled_result_types
            )
          nil
        end

        def result_builders
          @__result_builders__ ||= {}
        end
      end
    end
  end
end
