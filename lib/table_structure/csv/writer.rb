# frozen_string_literal: true

module TableStructure
  module CSV
    class Writer
      DEFAULT_OPTIONS = {
        bom: false,
        header_omitted: false,
        header_context: nil
      }.freeze

      FIXED_OPTIONS = {
        result_type: :array,
        method: :<<
      }.freeze

      BOM = "\uFEFF"

      def initialize(schema, **options)
        require 'csv'
        @options = DEFAULT_OPTIONS.merge(options).merge(FIXED_OPTIONS)
        @writer = ::TableStructure::Writer.new(schema, **@options)
      end

      def write(items, to:, **options)
        options = @options.merge(options).merge(FIXED_OPTIONS)
        to.send(options[:method], BOM) if options[:bom]
        @writer.write(items, to: ::CSV.new(to), **options)
      end
    end
  end
end
