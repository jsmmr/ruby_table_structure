# frozen_string_literal: true

module TableStructure
  module Schema
    class Table
      class ResultBuilder < Module
        def initialize(overrides, keys:, context: nil)
          table_context = context
          overrides
            .reject { |callables:, **| callables.nil? || callables.empty? }
            .each do |method:, callables:|
              define_method(method) do |context: nil|
                values = super(context: context)
                callables
                  .reduce(values) do |vals, (_, callable)|
                    callable.call(vals, keys, context, table_context)
                  end
              end
            end
        end
      end
    end
  end
end
