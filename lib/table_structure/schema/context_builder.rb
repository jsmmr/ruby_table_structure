# frozen_string_literal: true

module TableStructure
  module Schema
    class ContextBuilder
      extend Forwardable

      def_delegator :@callable, :call

      def initialize(callable)
        @callable = callable
      end
    end
  end
end
