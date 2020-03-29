# frozen_string_literal: true

module TableStructure
  module Schema
    module Definition
      class ContextBuilder
        extend Forwardable

        def_delegator :@callable, :call

        def initialize(&block)
          @callable = block
        end
      end
    end
  end
end
