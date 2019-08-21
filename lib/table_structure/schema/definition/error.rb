# frozen_string_literal: true

module TableStructure
  module Schema
    class Definition
      class Error < ::TableStructure::Error
        attr_reader :index

        def initialize(error_message, index)
          @index = index
          super("#{error_message} [defined position of column(s): #{index + 1}]")
        end
      end
    end
  end
end
