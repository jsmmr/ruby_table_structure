# frozen_string_literal: true

module TableStructure
  module Schema
    module ClassMethods
      def +(schema)
        self_schema = self
        Class.new do
          include ::TableStructure::Schema

          @__column_definitions__ = [
            self_schema.column_definitions,
            schema.column_definitions
          ].flatten

          @__context_builders__ =
            {}
            .merge!(self_schema.context_builders)
            .merge!(schema.context_builders)

          @__column_converters__ =
            {}
            .merge!(self_schema.column_converters)
            .merge!(schema.column_converters)

          @__result_builders__ =
            {}
            .merge!(self_schema.result_builders)
            .merge!(schema.result_builders)
        end
      end
    end
  end
end
