# frozen_string_literal: true

module TableStructure
  module Schema
    module Definition
      module Columns
        class Error < ::TableStructure::Error
          attr_reader :schema_name, :definition_index

          def initialize(error_message, schema_name, definition_index)
            @schema_name = schema_name
            @definition_index = definition_index
            super("#{error_message} [#{schema_name}] defined position of column(s): #{definition_index + 1}")
          end
        end
      end
    end
  end
end
