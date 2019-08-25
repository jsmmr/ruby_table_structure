# frozen_string_literal: true

module TableStructure
  module Schema
    class Definition
      class Validator
        DEFAULT_SIZE = 1

        def initialize(index, options)
          @index = index
          @options = options
        end

        def validate(name:, key:, size:, **)
          if key.respond_to?(:call)
            raise Error.new('"key" must not be lambda.', @index)
          end
          if !key && name.respond_to?(:call) && !size
            raise Error.new('"size" must be defined, because column size cannot be determined.', @index)
          end
          if size && size < DEFAULT_SIZE
            raise Error.new('"size" must be positive.', @index)
          end
          if @options[:result_type] == :hash && !key
            raise Error.new('"key" must be defined when "result_type: :hash" is specified.', @index)
          end
          if key && size && [key].flatten.size < size
            raise Error.new('"key" size must be greater than or equal to specified "size".', @index)
          end

          true
        end
      end
    end
  end
end
