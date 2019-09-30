# frozen_string_literal: true

module TableStructure
  module Schema
    class Table
      class ColumnConverter < Module
        def initialize(overrides, context: nil)
          table_context = context
          overrides
            .reject { |callables:, **| callables.nil? || callables.empty? }
            .each do |method:, callables:|
              define_method(method) do |context: nil|
                values = super(context: context)
                values.map do |val|
                  callables.reduce(val) do |val, (_, callable)|
                    callable.call(val, context, table_context)
                  end
                end
              end
            end
        end
      end
    end
  end
end
