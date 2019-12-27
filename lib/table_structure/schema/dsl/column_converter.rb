# frozen_string_literal: true

module TableStructure
  module Schema
    module DSL
      module ColumnConverter
        DEFAULT_OPTIONS = {
          header: true,
          row: true
        }.freeze

        def column_converter(name, callable, **options)
          options = DEFAULT_OPTIONS.merge(options)
          column_converters[name] = {
            callable: callable,
            options: options
          }
          nil
        end

        def column_converters
          @__column_converters__ ||= {}
        end
      end
    end
  end
end
