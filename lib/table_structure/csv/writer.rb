# frozen_string_literal: true

module TableStructure
  module CSV
    class Writer
      DEFAULT_OPTIONS = {
        bom: false,
        csv_options: {}
      }.freeze

      INNER_WRITER_DEFAULT_OPTIONS = ::TableStructure::Writer::DEFAULT_OPTIONS
      INNER_WRITER_IGNORED_OPTION_KEYS = %i[
        result_type
        method
      ].freeze

      BOM = "\uFEFF"

      def initialize(schema, **options)
        require 'csv'
        @options = DEFAULT_OPTIONS.merge(select_csv_writer_options(options))
        inner_writer_options = select_inner_writer_options(options)
        @writer = ::TableStructure::Writer.new(schema, **inner_writer_options)
      end

      def write(items, to:, **options, &block)
        csv_writer_options = @options.merge(select_csv_writer_options(options))
        inner_writer_options = select_inner_writer_options(options)
        if csv_writer_options[:bom]
          to.send(INNER_WRITER_DEFAULT_OPTIONS[:method], BOM)
        end
        csv = ::CSV.new(to, **csv_writer_options[:csv_options])
        @writer.write(items, to: csv, **inner_writer_options, &block)
      end

      private

      def select_csv_writer_options(options)
        options
          .select { |k, _v| DEFAULT_OPTIONS.include?(k) }
      end

      def select_inner_writer_options(options)
        options
          .select { |k, _v| INNER_WRITER_DEFAULT_OPTIONS.include?(k) }
          .reject do |k, v|
            ignored = INNER_WRITER_IGNORED_OPTION_KEYS.include?(k)
            if ignored
              warn "[TableStructure] #{self.class.name} ignores `#{k}:#{v}` option."
            end
            ignored
          end
      end
    end
  end
end
