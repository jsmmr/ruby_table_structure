# frozen_string_literal: true

module TableStructure
  module Schema
    class Definition
      DEFAULT_ATTRS = {
        name: nil,
        key: nil,
        value: nil,
        size: nil,
        omitted: false
      }.freeze

      DEFAULT_SIZE = 1

      def initialize(definitions, options)
        @definitions = definitions
        @options = options
      end

      def compile(context = nil)
        @definitions
          .map { |definition| Utils.evaluate_callable(definition, context) }
          .map.with_index do |definition, i|
            validator = Validator.new(i, @options)

            [definition]
              .flatten
              .map do |definition|
                if definition.is_a?(Hash)
                  definition = DEFAULT_ATTRS.merge(definition)
                  omitted = definition.delete(:omitted)
                  next if Utils.evaluate_callable(omitted, context)

                  validator.validate(definition)
                  definition[:size] = determine_size(definition)
                  definition
                elsif Utils.schema_instance?(definition)
                  definition
                # elsif Utils.schema_class?(definition)
                #   # TODO: This doesn't work as expected when result_type: :hash is specified.
                #   definition.new(context: context, **@options)
                end
              end
          end
          .flatten
          .compact
      end

      private

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
    end
  end
end
