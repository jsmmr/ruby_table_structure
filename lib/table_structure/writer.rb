module TableStructure
  class Writer

    DEFAULT_OPTIONS = {
      header_omitted: false,
      header_context: nil,
      method: :<<
    }

    def initialize(schema, **options)
      @schema = schema
      @options = DEFAULT_OPTIONS.merge(options)
    end

    def write(items, to:, **options)
      options = @options.merge(options)
      unless options[:header_omitted]
        header = @schema.header(context: options[:header_context])
        header = yield header if block_given?
        to.send(options[:method], header)
      end
      to_enum(items).each do |item|
        row = @schema.row(context: item)
        row = yield row if block_given?
        to.send(options[:method], row)
      end
      return
    end

    private

      def to_enum(items)
        items.respond_to?(:call) ?
          Enumerator.new { |y| items.call(y) } :
          items
      end
  end
end
