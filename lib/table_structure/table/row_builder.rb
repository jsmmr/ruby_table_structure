# frozen_string_literal: true

module TableStructure
  class Table::RowBuilder
    class ResultBuildable < Module
      def initialize(methods)
        methods.each do |name, method|
          define_method(name, &method)
        end
      end
    end

    class << self
      def create_module(builders, row_type:, keys:, context:)
        return if builders.empty?

        builders = builders.select { |_k, v| v.enabled?(row_type) }
        return if builders.empty?

        yield ResultBuildable.new(
          header: create_method(builders, keys, context),
          data: create_method(builders, keys, context)
        )
      end

      private

      def create_method(builders, table_keys, table_context)
        proc do |context: nil|
          builders
            .reduce(super(context: context)) do |vals, (_, builder)|
              builder.call(vals, table_keys, context, table_context)
            end
        end
      end
    end
  end
end
