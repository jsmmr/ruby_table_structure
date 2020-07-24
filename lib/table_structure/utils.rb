# frozen_string_literal: true

module TableStructure
  module Utils
    class Proc < ::Proc
      attr_reader :options

      def initialize(**options, &block)
        @options = options
        super(&block)
      end
    end

    class TypedProc < Proc
      def initialize(types:, **options, &block)
        @types = [types].flatten.compact
        super(**options, &block)
      end

      def typed?(type)
        @types.include?(type)
      end
    end

    class CompositeCallable
      def initialize
        @callables = []
      end

      def compose(*callables)
        @callables.concat(callables.flatten.compact)
        self
      end

      def call(source)
        @callables.reduce(source) { |memo, callable| callable.call(memo) }
      end
    end
  end
end
