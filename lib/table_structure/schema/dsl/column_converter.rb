# frozen_string_literal: true

module TableStructure
  module Schema
    module DSL
      module ColumnConverter
        def column_converter(
          name,
          header: true,
          body: true,
          **deprecated_options,
          &block
        )
          if deprecated_options.key?(:row)
            warn '[TableStructure] `:row` option has been deprecated. Use `:body` option instead.'
            body = deprecated_options[:row]
          end

          column_converters[name] =
            ::TableStructure::Schema::Definition::ColumnConverter.new(
              header: header,
              body: body,
              &block
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
