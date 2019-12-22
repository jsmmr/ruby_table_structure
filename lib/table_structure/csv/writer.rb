# frozen_string_literal: true

module TableStructure
  module CSV
    class Writer
      BOM = "\uFEFF"

      def initialize(
        schema,
        bom: false,
        csv_options: {},
        header_omitted: false,
        header_context: nil
      )
        require 'csv'

        @options = {
          bom: bom,
          csv_options: csv_options
        }
        @inner_options = {
          header_omitted: header_omitted,
          header_context: header_context
        }

        @writer = ::TableStructure::Writer.new(schema, **@inner_options)
      end

      def write(
        items,
        to:,
        bom: @options[:bom],
        csv_options: @options[:csv_options],
        header_omitted: @inner_options[:header_omitted],
        header_context: @inner_options[:header_context],
        &block
      )
        inner_options = {
          header_omitted: header_omitted,
          header_context: header_context
        }

        to << BOM if bom

        csv = ::CSV.new(to, **csv_options)
        @writer.write(items, to: csv, **inner_options, &block)
      end
    end
  end
end
