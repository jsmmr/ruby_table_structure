# frozen_string_literal: true

module TableStructure
  module Schema
    module Columns
      class Schema
        def initialize(schema)
          @schema = schema
          @header_row_generator = schema.create_header_row_generator
          @data_row_generator = schema.create_data_row_generator
        end

        def names(row_context, *)
          @header_row_generator.call(row_context).values
        end

        def keys
          @schema.columns_keys
        end

        def values(row_context, *)
          @data_row_generator.call(row_context).values
        end

        def size
          @schema.columns_size
        end

        def contain_callable?(attribute)
          @schema.contain_callable?(attribute)
        end
      end
    end
  end
end
