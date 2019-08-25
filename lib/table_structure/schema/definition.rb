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
              .map { |definition| DEFAULT_ATTRS.merge(definition) }
              .reject do |definition|
                omitted = definition.delete(:omitted)
                Utils.evaluate_callable(omitted, context)
              end
              .map do |definition|
                validator.validate(definition)
                definition[:size] = determine_size(definition)
                definition
              end
          end
          .flatten
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
