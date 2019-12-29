# frozen_string_literal: true

module TableStructure
  module Schema
    module ClassMethods
      def +(schema_class)
        self_schema_class = self
        ::TableStructure::Schema.create_class do
          @__column_definitions__ = [
            self_schema_class.column_definitions,
            schema_class.column_definitions
          ].flatten

          @__context_builders__ =
            {}
            .merge!(self_schema_class.context_builders)
            .merge!(schema_class.context_builders)

          @__column_converters__ =
            {}
            .merge!(self_schema_class.column_converters)
            .merge!(schema_class.column_converters)

          @__result_builders__ =
            {}
            .merge!(self_schema_class.result_builders)
            .merge!(schema_class.result_builders)
        end
      end
    end
  end
end
