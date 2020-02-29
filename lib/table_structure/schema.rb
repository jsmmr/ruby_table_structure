# frozen_string_literal: true

module TableStructure
  module Schema
    def self.included(klass)
      klass.extend(DSL::ColumnConverter)
      klass.extend(DSL::ColumnDefinition)
      klass.extend(DSL::ContextBuilder)
      klass.extend(DSL::Option)
      klass.extend(DSL::RowBuilder)
      klass.extend(ClassMethods)
    end

    def self.create_class(&block)
      raise ::TableStructure::Error, 'No block given.' unless block

      schema_module = self
      Class.new do
        include schema_module
        class_eval(&block)
      end
    end

    MyDefinition = Struct.new(
      :name,
      :columns,
      :context_builders,
      :column_converters,
      :row_builders,
      :context,
      :options
    )

    def initialize(
      name: self.class.name,
      context: nil,
      name_prefix: nil,
      name_suffix: nil,
      key_prefix: nil,
      key_suffix: nil,
      nil_definitions_ignored: false,
      **deprecated_options,
      &block
    )
      unless deprecated_options.empty?
        caller_location = caller_locations(1, 1)
        deprecated_options.keys.each do |k|
          warn "[TableStructure] Specify :#{k} option on Writer or Iterator. #{caller_location}"
        end
      end

      options = {
        name_prefix: name_prefix,
        name_suffix: name_suffix,
        key_prefix: key_prefix,
        key_suffix: key_suffix,
        nil_definitions_ignored: nil_definitions_ignored
      }.merge!(self.class.options).merge!(deprecated_options)

      schema_classes = [self.class]

      if block_given?
        schema_classes << ::TableStructure::Schema.create_class(&block)
      end

      context_builders = ContextBuilders.new(
        schema_classes.map(&:context_builders).reduce({}, &:merge!)
      )

      column_converters = ColumnConverters.new(
        schema_classes.map(&:column_converters).reduce({}, &:merge!)
      )

      row_builders = RowBuilders.new(
        schema_classes.map(&:row_builders).reduce({}, &:merge!)
      )

      table_context = context_builders.build_for_table(context)

      columns =
        Definition::Columns::Compiler
        .new(
          name,
          schema_classes.map(&:column_definitions).reduce([], &:concat),
          options
        )
        .compile(table_context)

      @_definition_ =
        MyDefinition.new(
          name,
          columns,
          context_builders,
          column_converters,
          row_builders,
          table_context,
          options
        )
    end

    def create_table(row_type: :array, **deprecated_options)
      options = @_definition_.options.merge(deprecated_options)

      if options.key?(:result_type)
        warn '[TableStructure] `:result_type` option has been deprecated. Use `:row_type` option instead.'
        options[:row_type] = options[:result_type]
      end

      keys_generator_options = {
        prefix: options[:key_prefix],
        suffix: options[:key_suffix]
      }

      keys_generator = KeysGenerator.new(
        **keys_generator_options
      )

      table = Table.new(
        columns: @_definition_.columns,
        context: @_definition_.context,
        keys_generator: keys_generator
      )

      @_definition_
        .context_builders
        .extend_methods_for(table)

      column_converters_options = {
        name_prefix: options[:name_prefix],
        name_suffix: options[:name_suffix]
      }

      @_definition_
        .column_converters
        .extend_methods_for(table, **column_converters_options)

      row_builders_options = {
        row_type: options[:row_type] || row_type
      }

      @_definition_
        .row_builders
        .extend_methods_for(table, **row_builders_options)

      if block_given?
        yield table
      else
        table
      end
    end
  end
end
