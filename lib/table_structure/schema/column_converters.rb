# frozen_string_literal: true

module TableStructure
  module Schema
    class ColumnConverters
      def initialize(converters)
        @header_converters = select_converters_for(:header, converters)
        @row_converters = select_converters_for(:row, converters)
      end

      def extend_methods_for(table)
        table_context = table.instance_variable_get(:@context)
        table_options = table.instance_variable_get(:@options)

        header_converters = optional_header_converters(table_options).merge(@header_converters)
        row_converters = @row_converters

        methods = {}
        unless header_converters.empty?
          methods[:header] = create_method(header_converters, table_context)
        end
        unless row_converters.empty?
          methods[:row] = create_method(row_converters, table_context)
        end

        return if methods.empty?

        table.extend ColumnConverter.new(methods)
      end

      private

      def select_converters_for(method, converters)
        converters
          .select { |_k, v| v[:options][method] }
          .map { |k, v| [k, v[:callable]] }
          .to_h
      end

      def optional_header_converters(options)
        converters = {}
        if options[:name_prefix]
          converters[:_prepend_prefix_] =
            create_prefix_converter(options[:name_prefix])
        end
        if options[:name_suffix]
          converters[:_append_suffix_] =
            create_suffix_converter(options[:name_suffix])
        end

        converters
      end

      def create_prefix_converter(prefix)
        lambda { |val, *|
          val.nil? ? val : "#{prefix}#{val}"
        }
      end

      def create_suffix_converter(suffix)
        lambda { |val, *|
          val.nil? ? val : "#{val}#{suffix}"
        }
      end

      def create_method(converters, table_context)
        proc do |context: nil|
          values = super(context: context)
          values.map do |val|
            converters.reduce(val) do |val, (_, converter)|
              converter.call(val, context, table_context)
            end
          end
        end
      end
    end

    class ColumnConverter < Module
      def initialize(methods)
        methods.each do |name, method|
          define_method(name, &method)
        end
      end
    end
  end
end
