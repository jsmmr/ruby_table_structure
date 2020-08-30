# frozen_string_literal: true

module TableStructure
  module Schema
    module Columns
      class Attributes
        attr_reader :keys, :size

        def initialize(name:, key:, value:, size:)
          @name_callable = Utils.callable?(name)
          @name = @name_callable ? name : proc { name }
          @keys = Column::Utils.optimize_values([key].flatten, size: size)
          @value_callable = Utils.callable?(value)
          @value = @value_callable ? value : proc { value }
          @size = size
        end

        def names(context, table_context)
          names = @name.call(context, table_context)
          Column::Utils.optimize_values(names, size: @size)
        end

        def values(context, table_context)
          values = @value.call(context, table_context)
          Column::Utils.optimize_values(values, size: @size)
        end

        def name_callable?
          @name_callable
        end

        def value_callable?
          @value_callable
        end
      end
    end
  end
end
