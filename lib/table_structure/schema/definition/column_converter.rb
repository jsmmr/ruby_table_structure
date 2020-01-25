# frozen_string_literal: true

module TableStructure
  module Schema
    module Definition
      class ColumnConverter
        extend Forwardable

        def_delegator :@callable, :call

        def initialize(
          callable,
          header: true,
          body: true
        )
          @callable = callable
          @applicable_to_header = header
          @applicable_to_body = body
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
