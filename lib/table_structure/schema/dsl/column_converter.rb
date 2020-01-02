# frozen_string_literal: true

module TableStructure
  module Schema
    module DSL
      module ColumnConverter
        def column_converter(
          name,
          callable,
          header: true,
          row: true
        )
          column_converters[name] =
            ::TableStructure::Schema::ColumnConverter.new(
              callable,
              header: header,
              row: row
            )
          nil
        end

        def column_converters
          @__column_converters__ ||= {}
        end
      end
    end
  end
end
