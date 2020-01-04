# frozen_string_literal: true

module TableStructure
  module Schema
    module Definition
      module Columns
        class SchemaClass
          def initialize(definition)
            @definition = definition
          end

          def omitted?(**)
            false
          end

          def compile(context:)
            instance = @definition.new(context: context)
            ::TableStructure::Schema::Columns::Schema.new(instance)
          end
        end
      end
    end
  end
end
