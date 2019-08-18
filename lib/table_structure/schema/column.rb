# frozen_string_literal: true

module TableStructure
  module Schema
    class Column
      class Error < ::TableStructure::Error
        attr_reader :group_index

        def initialize(error_message, group_index)
          @group_index = group_index
          super("#{error_message} [defined position: #{group_index + 1}]")
        end
      end

      DEFAULT_DEFINITION = {
        name: nil,
        key: nil,
        value: nil,
        size: nil
      }.freeze

      DEFAULT_SIZE = 1

      attr_reader :size, :group_index

      def initialize(definition, group_index)
        @group_index = group_index
        definition = DEFAULT_DEFINITION.merge(definition)
        validate(definition)
        @name = definition[:name]
        @key = definition[:key]
        @value = definition[:value]
        @size = determine_size(definition)
      end

      def name(header_context, table_context)
        val = Utils.evaluate_callable(@name, header_context, table_context)
        optimize_size(val)
      end

      def key
        optimize_size(@key)
      end

      def value(row_context, table_context)
        val = Utils.evaluate_callable(@value, row_context, table_context)
        optimize_size(val)
      end

      private

      def validate(name:, key:, size:, **)
        if !key && name.respond_to?(:call) && !size
          raise Error.new('"size" must be specified, because column size cannot be determined.', @group_index)
        end
        if size && size < DEFAULT_SIZE
          raise Error.new('"size" must be positive.', @group_index)
        end
      end

      def determine_size(name:, key:, size:, **)
        return size if size

        [calculate_size(name), calculate_size(key)].max
      end

      def calculate_size(val)
        if val.is_a?(Array)
          return val.empty? ? DEFAULT_SIZE : val.size
        end

        DEFAULT_SIZE
      end

      def multiple?
        @size > DEFAULT_SIZE
      end

      def optimize_size(value)
        return value unless multiple?

        values = value.is_a?(Array) ? value : [value]
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
