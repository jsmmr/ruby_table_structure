# frozen_string_literal: true

module TableStructure
  module Schema
    class ResultBuilders
      DEFAULT_BUILDERS = {
        _to_hash_: {
          callable: lambda { |values, keys, *|
            keys.map.with_index { |key, i| [key || i, values[i]] }.to_h
          },
          options: {
            enabled_result_types: [:hash]
          }
        }
      }.freeze

      def initialize(builders)
        @builders = builders
      end

      def extend_methods_for(table)
        table_context = table.instance_variable_get(:@context)
        table_options = table.instance_variable_get(:@options)
        table_keys = table.send(:keys)

        builders = select_builders(table_options[:result_type])

        methods = {}
        unless builders.empty?
          methods[:header] = create_method(builders, table_keys, table_context)
          methods[:row] = create_method(builders, table_keys, table_context)
        end

        return if methods.empty?

        table.extend ResultBuilder.new(methods)
      end

      private

      def select_builders(result_type)
        DEFAULT_BUILDERS
          .merge(@builders)
          .select { |_k, v| v[:options][:enabled_result_types].include?(result_type) }
          .map { |k, v| [k, v[:callable]] }
          .to_h
      end

      def create_method(builders, table_keys, table_context)
        proc do |context: nil|
          values = super(context: context)
          builders
            .reduce(values) do |vals, (_, builder)|
              builder.call(vals, table_keys, context, table_context)
            end
        end
      end
    end

    class ResultBuilder < Module
      def initialize(methods)
        methods.each do |name, method|
          define_method(name, &method)
        end
      end
    end
  end
end
