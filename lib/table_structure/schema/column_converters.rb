# frozen_string_literal: true

module TableStructure
  module Schema
    class ColumnConverters
      def initialize(converters)
        @header_converters = converters.select { |_k, v| v.applicable_to_header? }
        @body_converterss = converters.select { |_k, v| v.applicable_to_body? }
      end

      def extend_methods_for(table, name_prefix:, name_suffix:)
        table_context = table.instance_variable_get(:@context)

        header_converters =
          @header_converters
          .merge(
            _prepend_prefix_: create_prepender(name_prefix),
            _append_suffix_: create_appender(name_suffix)
          )
          .reject { |_k, v| v.nil? }

        body_converterss = @body_converterss

        methods =
          {
            header: create_method(header_converters, table_context),
            data: create_method(body_converterss, table_context)
          }
          .reject { |_k, v| v.nil? }

        return if methods.empty?

        table.extend ColumnConvertible.new(methods)
      end

      private

      def create_prepender(prefix)
        return unless prefix

        Definition::ColumnConverter.new(
          lambda { |val, *|
            val.nil? ? val : "#{prefix}#{val}"
          },
          header: true,
          body: false
        )
      end

      def create_appender(suffix)
        return unless suffix

        Definition::ColumnConverter.new(
          lambda { |val, *|
            val.nil? ? val : "#{val}#{suffix}"
          },
          header: true,
          body: false
        )
      end

      def create_method(converters, table_context)
        return if converters.empty?

        proc do |context: nil|
          super(context: context).map do |val|
            converters.reduce(val) do |val, (_, converter)|
              converter.call(val, context, table_context)
            end
          end
        end
      end
    end

    class ColumnConvertible < Module
      def initialize(methods)
        methods.each do |name, method|
          define_method(name, &method)
        end
      end
    end
  end
end
