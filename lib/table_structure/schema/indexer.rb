# frozen_string_literal: true

module TableStructure
  module Schema
    class Indexer
      def initialize
        @i = 0
      end

      def next_values(size: 1)
        first = @i
        last = @i = @i + size
        (first...last).to_a
      end
    end
  end
end
