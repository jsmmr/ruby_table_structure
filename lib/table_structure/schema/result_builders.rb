# frozen_string_literal: true

module TableStructure
  module Schema
    class ResultBuilders
      DEFAULT_BUILDERS = {
        _to_hash_: ::TableStructure::Schema::ResultBuilder.new(
          lambda { |values, keys, *|
            keys.map.with_index { |key, i| [key || i, values[i]] }.to_h
          },
          enabled_result_types: [:hash]
        )
      }.freeze

      def initialize(builders)
        @builders = builders
      end

      def extend_methods_for(table, result_type: :array)
        builders =
          DEFAULT_BUILDERS
          .merge(@builders)
          .select { |_k, v| v.enabled?(result_type) }

        return if builders.empty?

        table_context = table.instance_variable_get(:@context)
        table_keys = table.send(:keys)

        table.extend ResultBuildable.new(
          header: create_method(builders, table_keys, table_context),
          row: create_method(builders, table_keys, table_context)
        )
      end

      private

      def create_method(builders, table_keys, table_context)
        return if builders.empty?

        proc do |context: nil|
          builders
            .reduce(super(context: context)) do |vals, (_, builder)|
              builder.call(vals, table_keys, context, table_context)
            end
        end
      end
    end

    class ResultBuildable < Module
      def initialize(methods)
        methods.each do |name, method|
          define_method(name, &method)
        end
      end
    end
  end
end
