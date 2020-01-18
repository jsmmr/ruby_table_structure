# frozen_string_literal: true

module TableStructure
  module Schema
    module Columns
      class Schema
        def initialize(schema)
          @table = schema.create_table
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
      end
    end
  end
end
