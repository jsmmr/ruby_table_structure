# frozen_string_literal: true

module TableStructure
  module Schema
    module Column
      class Schema
        attr_reader :schema, :indexes

        def initialize(schema, indexer)
          @schema = schema
          @indexes = indexer.next_values(size: size)
        end

        def name(header_context, _table_context)
          @schema.header(context: header_context)
        end

        def key
          table.send(:keys)
        end

        def value(row_context, _table_context)
          @schema.row(context: row_context)
        end

        def size
          table.send(:size)
        end

        private

        def table
          @schema.instance_variable_get(:@table_structure_schema_table_)
        end
      end
    end
  end
end
