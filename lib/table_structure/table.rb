# frozen_string_literal: true

module TableStructure
  class Table
    DEFAULT_ROW_BUILDERS = {
      _to_hash_: Utils::TypedProc.new(
        types: :hash
      ) do |values, keys|
        keys.map.with_index { |key, i| [key || i, values[i]] }.to_h
      end
    }.freeze

    def initialize(schema, row_type: :array)
      @header_row_generator = schema.create_header_row_generator
      @data_row_generator = schema.create_data_row_generator

      row_builders =
        DEFAULT_ROW_BUILDERS
        .merge(schema.row_builders)
        .select { |_k, v| v.typed?(row_type) }
        .values

      unless row_builders.empty?
        row_build_task = proc do |row|
          row.values = row_builders.reduce(row.values) do |values, builder|
            builder.call(values, row.keys, row.context, schema.context)
          end
          row
        end
        @header_row_generator.compose(row_build_task)
        @data_row_generator.compose(row_build_task)
      end

      yield self if block_given?
    end

    def header(context: nil)
      @header_row_generator.call(context).values
    end

    def body(contexts)
      ::Enumerator.new do |y|
        contexts.each { |context| y << @data_row_generator.call(context).values }
      end
    end
  end
end
