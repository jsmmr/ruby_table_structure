# frozen_string_literal: true

module TableStructure
  module Schema
    module Column
      module Definition
        class Validator
          DEFAULT_SIZE = 1

          def initialize(name, index)
            @name = name
            @index = index
          end

          def validate(name:, key:, size:, **)
            if key.respond_to?(:call)
              raise Error.new('"key" must not be lambda.', @name, @index)
            end
            if !key && name.respond_to?(:call) && !size
              raise Error.new('"size" must be defined, because column size cannot be determined.', @name, @index)
            end
            if size && size < DEFAULT_SIZE
              raise Error.new('"size" must be positive.', @name, @index)
            end
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
