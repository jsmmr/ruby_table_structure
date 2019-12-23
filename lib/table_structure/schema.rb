# frozen_string_literal: true

module TableStructure
  module Schema
    def self.included(klass)
      klass.extend(DSL::ColumnConverter)
      klass.extend(DSL::ColumnDefinition)
      klass.extend(DSL::ContextBuilder)
      klass.extend(DSL::Option)
      klass.extend(DSL::ResultBuilder)
      klass.extend(ClassMethods)
    end

    Definition = Struct.new(
      'Definition',
      :name,
      :columns,
      :context_builders,
      :column_converters,
      :result_builders,
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
      **deprecated_options
    )
      unless deprecated_options.empty?
        caller_location = caller_locations(1, 1)
        deprecated_options.keys.each do |k|
          warn "[TableStructure] Specify :#{k} option on the writer or the iterator. #{caller_location}"
        end
      end

      options = {
        name_prefix: name_prefix,
        name_suffix: name_suffix,
        key_prefix: key_prefix,
        key_suffix: key_suffix,
        nil_definitions_ignored: nil_definitions_ignored
      }.merge!(self.class.options).merge!(deprecated_options)

      context_builders = ContextBuilders.new({}.merge!(self.class.context_builders))
      column_converters = ColumnConverters.new({}.merge!(self.class.column_converters))
      result_builders = ResultBuilders.new({}.merge!(self.class.result_builders))

      context = context_builders.build_for_table(context)
      columns = Column::Factory.create(name, self.class.column_definitions, context, options)

      @_definition_ =
        Definition.new(
          name,
          columns,
          context_builders,
          column_converters,
          result_builders,
          context,
          options
        )
    end

    # TODO: Specify options using keyword arguments.
    def create_table(**options)
      options = @_definition_.options.merge(options)

      table = Table.new(
        @_definition_.columns,
        @_definition_.context,
        options
      )

      @_definition_.context_builders.extend_methods_for(table)

      column_converters_options = {
        name_prefix: options[:name_prefix],
        name_suffix: options[:name_suffix]
      }

      @_definition_.column_converters.extend_methods_for(table, **column_converters_options)

      result_builders_options = {
        result_type: options[:result_type]
      }

      @_definition_.result_builders.extend_methods_for(table, **result_builders_options)

      if block_given?
        yield table
      else
        table
      end
    end
  end
end
