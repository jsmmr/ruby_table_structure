# frozen_string_literal: true

module TableStructure
  module Schema
    class Definition
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
        @name = name
        @context_builders = ContextBuilders.new(context_builders)
        @column_converters = ColumnConverters.new(column_converters)
        @result_builders = ResultBuilders.new(result_builders)
        @context = @context_builders.build_for_table(context)
        @options = options

        @columns = create_columns(@name, column_definitions, @context, @options)
      end

      def create_table(**options)
        options = @options.merge(options)

        table = Table.new(
          @columns,
          @context,
          options
        )

        @context_builders.extend_methods_for(table)
        @column_converters.extend_methods_for(table)
        @result_builders.extend_methods_for(table)

        if block_given?
          yield table
        else
          table
        end
      end

      private

      def create_columns(name, definitions, context, options)
        Compiler
          .new(name, definitions, options)
          .compile(context)
          .map do |definition|
            if definition.is_a?(Hash)
              Column::Attrs.new(definition)
            else
              Column::Schema.new(definition)
            end
          end
      end
    end
  end
end
