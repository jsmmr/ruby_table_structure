# frozen_string_literal: true

module TableStructure
  module Schema
    class Definition
      class Validator
        DEFAULT_SIZE = 1

        def initialize(index)
          @index = index
        end

        def validate(name:, key:, size:, **)
          if !key && name.respond_to?(:call) && !size
            raise Error.new('"size" must be specified, because column size cannot be determined.', @index)
          end
          if size && size < DEFAULT_SIZE
            raise Error.new('"size" must be positive.', @index)
          end

          true
        end
      end
    end
  end
end
