# frozen_string_literal: true

module TableStructure
  class Writer
    DEFAULT_OPTIONS = {
      header_omitted: false,
      header_context: nil,
      result_type: nil, # TODO: :array
      method: :<<
    }.freeze

    def initialize(schema, **options)
      @schema = schema
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def write(items, to:, **options)
      options = @options.merge(options)
      unless options[:header_omitted]
        header = @schema.header(
          context: options[:header_context],
          result_type: options[:result_type]
        )
        header = yield header if block_given?
        to.send(options[:method], header)
      end
      enumerize(items).each do |item|
        row = @schema.row(
          context: item,
          result_type: options[:result_type]
        )
        row = yield row if block_given?
        to.send(options[:method], row)
      end
      nil
    end

    private

    def enumerize(items)
      items.respond_to?(:call) ?
        Enumerator.new { |y| items.call(y) } :
        items
    end
  end
end
