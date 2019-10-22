# frozen_string_literal: true

module TableStructure
  class Writer
    DEFAULT_OPTIONS = {
      header_omitted: false,
      header_context: nil,
      result_type: :array,
      method: :<<
    }.freeze

    def initialize(schema, **options)
      @schema = schema
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def write(items, to:, **options)
      options = @options.merge(options)
      table = @schema.create_table(options)
      unless options[:header_omitted]
        header = table.header(
          context: options[:header_context]
        )
        header = yield header if block_given?
        to.send(options[:method], header)
      end
      enumerize(items).each do |item|
        row = table.row(context: item)
        row = yield row if block_given?
        to.send(options[:method], row)
      end
      nil
    end

    private

    def enumerize(items)
      if items.respond_to?(:each)
        items
      elsif items.respond_to?(:call)
        warn "[TableStructure] Use `Enumerator` instead of `lambda` to wrap items. `lambda` has been deprecated. #{items}"
        Enumerator.new { |y| items.call(y) }
      else
        raise ::TableStructure::Error, 'Items is not enumerable.'
      end
    end
  end
end
