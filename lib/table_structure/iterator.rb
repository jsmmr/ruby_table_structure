# frozen_string_literal: true

module TableStructure
  class Iterator
    class HeaderOptions
      attr_reader :enabled, :context, :step
      alias enabled? enabled

      def initialize(options)
        @enabled = !!options
        if options.is_a?(Hash)
          @context = options[:context]
          @step = options[:step]
        end

        validate
      end

      private

      def validate
        if @step
          raise ::TableStructure::Error, ':step must be numeric.' unless @step.is_a?(Numeric)
          raise ::TableStructure::Error, ':step must be positive number.' unless @step.positive?
        end
      end
    end

    def initialize(
      schema,
      header: { context: nil, step: nil },
      row_type: :array
    )
      @table = Table.new(schema, row_type: row_type)
      @header_options = HeaderOptions.new(header)
    end

    def iterate(items, &block)
      raise ::TableStructure::Error, "Must be enumerable. #{items}" unless items.respond_to?(:each)

      table_enum = ::Enumerator.new do |y|
        body_enum = @table.body(items)

        if @header_options.enabled?
          header_row = @table.header(context: @header_options.context)
          y << header_row

          if @header_options.step
            loop do
              @header_options.step.times { y << body_enum.next }
              y << header_row
            end
          else
            body_enum.each { |row| y << row }
          end
        else
          body_enum.each { |row| y << row }
        end
      end

      table_enum = table_enum.lazy.map(&block) if block_given?

      table_enum
    end
  end
end
