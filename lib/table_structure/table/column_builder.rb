# frozen_string_literal: true

module TableStructure
  class Table::ColumnBuilder
    class ColumnConvertible < Module
      def initialize(methods)
        methods.each do |name, method|
          define_method(name, &method)
        end
      end
    end

    class << self
      def create_module(converters, context:)
        return if converters.empty?

        header_converters = converters.select { |_k, v| v.applicable_to_header? }
        body_converters = converters.select { |_k, v| v.applicable_to_body? }

        methods = {}

        methods[:header] = create_method(header_converters, context) unless header_converters.empty?

        methods[:data] = create_method(body_converters, context) unless body_converters.empty?

        yield ColumnConvertible.new(methods)
      end

      private

      def create_method(converters, table_context)
        proc do |context: nil|
          super(context: context).map do |val|
            converters.reduce(val) do |val, (_, converter)|
              converter.call(val, context, table_context)
            end
          end
        end
      end
    end
  end
end
