# frozen_string_literal: true

module TableStructure
  module Schema
    module Definition
      module Columns
        class Validator
          DEFAULT_SIZE = 1

          def initialize(name, index)
            @name = name
            @index = index
          end

          def validate(name:, key:, size:, **)
            raise Error.new('"key" must not be lambda.', @name, @index) if key.respond_to?(:call)
            if !key && name.respond_to?(:call) && !size
              raise Error.new('"size" must be defined, because column size cannot be determined.', @name, @index)
            end
            raise Error.new('"size" must be positive.', @name, @index) if size && size < DEFAULT_SIZE
            if key && size && [key].flatten.size < size
              raise Error.new('"key" size must not be less than specified "size".', @name, @index)
            end

            true
          end
        end
      end
    end
  end
end
