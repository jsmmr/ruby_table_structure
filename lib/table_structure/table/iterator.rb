# frozen_string_literal: true

module TableStructure
  module Table
    class Iterator
      def initialize(table, header: { context: nil })
        @table = table
        @header_options = header
      end

      def iterate(items)
        ::Enumerator.new do |y|
          if @header_options
            header_context = @header_options.is_a?(Hash) ? @header_options[:context] : nil
            y << @table.header(context: header_context)
          end
          @table
            .body(items)
            .each { |row| y << row }
        end
      end
    end
  end
end
