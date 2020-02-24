# frozen_string_literal: true

module TableStructure
  module CSV
    class Writer
      BOM = "\uFEFF"

      def initialize(
        schema,
        bom: false,
        csv_options: {},
        header: { context: nil },
        **deprecated_options
      )
        if deprecated_options.key?(:header_omitted)
          header_omitted = deprecated_options[:header_omitted]
          warn "[TableStructure] `header_omitted: #{!!header_omitted}` option has been deprecated. Use `header: #{!header_omitted}` option instead."
          header = !header_omitted
        end

        if deprecated_options.key?(:header_context)
          header_context = deprecated_options[:header_context]
          warn '[TableStructure] `:header_context` option has been deprecated. Use `header: { context: ... }` option instead.'
          header = { context: header_context }
        end

        require 'csv'

        @options = {
          bom: bom,
          csv_options: csv_options
        }
        @inner_options = {
          header: header
        }

        @writer = ::TableStructure::Writer.new(schema, **@inner_options)
      end

      def write(
        items,
        to:,
        bom: @options[:bom],
        csv_options: @options[:csv_options],
        header: @inner_options[:header],
        **deprecated_options,
        &block
      )
        if deprecated_options.key?(:header_omitted)
          header_omitted = deprecated_options[:header_omitted]
          warn "[TableStructure] `header_omitted: #{!!header_omitted}` option has been deprecated. Use `header: #{!header_omitted}` option instead."
          header = !header_omitted
        end

        if deprecated_options.key?(:header_context)
          header_context = deprecated_options[:header_context]
          warn '[TableStructure] `:header_context` option has been deprecated. Use `header: { context: ... }` option instead.'
          header = { context: header_context }
        end

        inner_options = {
          header: header
        }

        to << BOM if bom

        csv = ::CSV.new(to, **csv_options)
        @writer.write(items, to: csv, **inner_options, &block)
      end
    end
  end
end
