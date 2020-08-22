# frozen_string_literal: true

module TableStructure
  module Schema
    module ClassMethods
      def +(other)
        raise ::TableStructure::Error, "Must be a schema class. [#{other}]" unless Utils.schema_class?(other)

        self_class = self

        Schema.create_class do
          columns self_class
          columns other
        end
      end

      def merge(*others)
        others.each do |other|
          raise ::TableStructure::Error, "Must be a schema class. [#{other}]" unless Utils.schema_class?(other)
        end

        schema_class = CompositeClass.new.compose(self, *others)

        Schema.create_class do
          @__column_definitions__ = schema_class.column_definitions
          @__context_builders__ = schema_class.context_builders
          @__column_builders__ = schema_class.column_builders
          @__row_builders__ = schema_class.row_builders
        end
      end
    end
  end
end
