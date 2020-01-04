# frozen_string_literal: true

module TableStructure
  module Schema
    module Definition
      class ResultBuilder
        extend Forwardable

        def_delegator :@callable, :call

        def initialize(
          callable,
          enabled_result_types: %i[array hash]
        )
          @callable = callable
          @enabled_result_types = [enabled_result_types].flatten
        end

        def enabled?(result_type)
          @enabled_result_types.include?(result_type)
        end
      end
    end
  end
end
