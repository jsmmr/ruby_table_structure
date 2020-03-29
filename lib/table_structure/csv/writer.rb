# frozen_string_literal: true

module TableStructure
  module CSV
    class Writer
      BOM = "\uFEFF"

      def initialize(
        schema,
        bom: false,
        csv_options: {},
        header: { context: nil }
      )
        require 'csv'

        @options = {
          bom: bom,
          csv_options: csv_options
        }
        inner_options = {
          header: header
        }

        @writer = ::TableStructure::Writer.new(schema, **inner_options)
      end

      def write(
        items,
        to:,
        bom: @options[:bom],
        csv_options: @options[:csv_options],
        &block
      )
        to << BOM if bom

        csv = ::CSV.new(to, **csv_options)
        @writer.write(items, to: csv, &block)
      end
    end
  end
end
