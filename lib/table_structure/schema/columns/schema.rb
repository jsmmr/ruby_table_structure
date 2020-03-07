# frozen_string_literal: true

module TableStructure
  module Schema
    module Columns
      class Schema
        def initialize(schema)
          @schema = schema
          @table = ::TableStructure::Table.new(schema)
        end

        def names(header_context, _table_context)
          @table.header(context: header_context)
        end

        def keys
          @table.send(:keys)
        end

        def values(row_context, _table_context)
          @table.send(:data, context: row_context)
        end

        def size
          @table.send(:size)
        end

        def contain_callable?(attribute)
          @schema.contain_callable?(attribute)
        end
      end
    end
  end
end
