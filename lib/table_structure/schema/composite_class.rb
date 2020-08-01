# frozen_string_literal: true

module TableStructure
  module Schema
    class CompositeClass
      def initialize
        @classes = []
      end

      def compose(*classes)
        @classes.concat(classes.flatten.compact)
        self
      end

      def column_definitions
        @classes
          .map(&:column_definitions)
          .flatten
      end

      def context_builders
        @classes
          .map(&:context_builders)
          .reduce({}, &:merge!)
      end

      def column_builders
        @classes
          .map(&:column_builders)
          .reduce({}, &:merge!)
      end

      def row_builders
        @classes
          .map(&:row_builders)
          .reduce({}, &:merge!)
      end
    end
  end
end
