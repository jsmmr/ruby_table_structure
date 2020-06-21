# frozen_string_literal: true

module TableStructure
  module Schema
    module Definition
      class ColumnBuilder
        extend Forwardable

        def_delegator :@callable, :call

        def initialize(
          header: true,
          body: true,
          &block
        )
          @applicable_to_header = header
          @applicable_to_body = body
          @callable = block
        end

        def applicable_to_header?
          !!@applicable_to_header
        end

        def applicable_to_body?
          !!@applicable_to_body
        end
      end
    end
  end
end
