# frozen_string_literal: true

module TableStructure
  module Schema
    module DSL
      module ResultBuilder
        DEFAULT_OPTIONS = {
          enabled_result_types: %i[array hash]
        }.freeze

        def result_builder(name, callable, **options)
          options = DEFAULT_OPTIONS.merge(options)
          options[:enabled_result_types] = [options[:enabled_result_types]].flatten
          result_builders[name] = {
            callable: callable,
            options: options
          }
          nil
        end

        def result_builders
          @__result_builders__ ||= {}
        end
      end
    end
  end
end
