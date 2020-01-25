# frozen_string_literal: true

module TableStructure
  module Schema
    module Definition
      module Columns
        class SchemaInstance
          def initialize(definition)
            @definition = definition
          end

          def omitted?(**)
            false
          end

          def compile(**)
            ::TableStructure::Schema::Columns::Schema.new(@definition)
          end
        end
      end
    end
  end
end
