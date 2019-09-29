# frozen_string_literal: true

module TableStructure
  module Schema
    class Definition
      RESULT_BUILDERS = {
        hash: lambda { |values, keys, *|
          keys.map.with_index { |key, i| [key || i, values[i]] }.to_h
        }
      }.freeze

      attr_reader :options

      def initialize(
        name,
        column_definitions,
        context_builders,
        column_converters,
        result_builders,
        context,
        options
      )
        table_context_builder = context_builders.delete(:table)
        context = table_context_builder.call(context) if table_context_builder

        @name = name
        @columns = create_columns(name, column_definitions, context, options)
        @header_context_builder = Table::ContextBuilder.new(:header, context_builders[:header])
        @row_context_builder = Table::ContextBuilder.new(:row, context_builders[:row])
        @header_column_converters = select_column_converters(:header, column_converters)
        @row_column_converters = select_column_converters(:row, column_converters)
        @result_builders = result_builders
        @context = context
        @options = options
      end

      def create_table(result_type: :array, **options)
        options = @options.merge(options)

        header_column_converters =
          optional_header_column_converters(options).merge(@header_column_converters)

        result_builders =
          RESULT_BUILDERS
          .select { |k, _v| k == result_type }
          .merge(@result_builders)

        Table.new(
          @columns,
          @header_context_builder,
          @row_context_builder,
          header_column_converters,
          @row_column_converters,
          result_builders,
          @context,
          options
        )
      end

      private

      def create_columns(name, definitions, context, options)
        Compiler
          .new(name, definitions, options)
          .compile(context)
          .map { |definition| Column.create(definition, options) }
      end

      def select_column_converters(type, column_converters)
        column_converters
          .select { |_k, v| v[:options][type] }
          .map { |k, v| [k, v[:callable]] }
          .to_h
      end

      def optional_header_column_converters(options)
        column_converters = {}
        if options[:name_prefix]
          column_converters[:_prepend_prefix] = lambda { |val, *|
            val.nil? ? val : "#{options[:name_prefix]}#{val}"
          }
        end
        if options[:name_suffix]
          column_converters[:_append_suffix] = lambda { |val, *|
            val.nil? ? val : "#{val}#{options[:name_suffix]}"
          }
        end

        column_converters
      end
    end
  end
end
