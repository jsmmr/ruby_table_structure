# frozen_string_literal: true

module TableStructure
  module Schema
    module ClassMethods
      def merge(*others)
        others.each do |other|
          unless ::TableStructure::Schema::Utils.schema_class?(other)
            raise ::TableStructure::Error, "Must be a schema class. #{other}"
          end
        end

        schema_classes = [self, *others]

        ::TableStructure::Schema.create_class do
          @__column_definitions__ =
            schema_classes
            .map(&:column_definitions)
            .flatten

          @__context_builders__ =
            schema_classes
            .map(&:context_builders)
            .reduce({}, &:merge!)

          @__column_converters__ =
            schema_classes
            .map(&:column_converters)
            .reduce({}, &:merge!)

          @__result_builders__ =
            schema_classes
            .map(&:result_builders)
            .reduce({}, &:merge!)
        end
      end
    end
  end
end
