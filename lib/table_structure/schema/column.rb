module TableStructure
  module Schema
    class Column

      DEFAULT_SIZE = 1

      def initialize(name: nil, key: nil, value: nil, size: nil)
        @name = name
        @key = key
        @value = value
        @size = determine_size(specified_size: size)
      end

      def name(header_context, table_context)
        val = Utils.evaluate_callable(@name, header_context, table_context)
        optimize_size(val)
      end

      def key
        @key
      end

      def value(row_context, table_context)
        val = Utils.evaluate_callable(@value, row_context, table_context)
        optimize_size(val)
      end

      private

        def determine_size(specified_size:)
          if @name.respond_to?(:call) && !specified_size
            raise ::TableStructure::Error.new('"size" must be specified, because column size cannot be determined.')
          end
          if specified_size
            if specified_size < DEFAULT_SIZE
              raise ::TableStructure::Error.new('"size" must be positive.')
            end
            return specified_size
          end
          if @name.kind_of?(Array)
            return @name.empty? ? DEFAULT_SIZE : @name.size
          end
          DEFAULT_SIZE
        end

        def multiple?
          @size > DEFAULT_SIZE
        end

        def optimize_size(value)
          return value unless multiple?
          values = value.kind_of?(Array) ? value : [value]
          actual_size = values.size
          if actual_size > @size
            values[0, @size]
          elsif actual_size < @size
            [].concat(values).fill(nil, actual_size, (@size - actual_size))
          else
            values
          end
        end
    end
  end
end
