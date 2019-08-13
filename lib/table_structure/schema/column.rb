module TableStructure
  module Schema
    class Column
      def initialize(name: nil, key: nil, value:, size: nil)
        @name = name
        @key = key
        @value = value
        @size = specify_size(specified_size: size)
      end

      def name(header_context, table_context)
        Utils.evaluate_callable(@name, header_context, table_context)
      end

      def key
        @key
      end

      def value(row_context, table_context)
        val = Utils.evaluate_callable(@value, row_context, table_context)
        optimize_size(val)
      end

      private

        def specify_size(specified_size:)
          if @name.kind_of?(Array)
            @name.size
          elsif @name.respond_to?(:call)
            unless specified_size
              raise ::TableStructure::Error.new(
                ":size must be specified when :name is lambda, because columns size is ambiguous."
              )
            end
            specified_size
          else
            1
          end
        end

        def multiple?
          @size > 1
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
