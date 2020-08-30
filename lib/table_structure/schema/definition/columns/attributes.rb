# frozen_string_literal: true

module TableStructure
  module Schema
    module Definition
      module Columns
        class Attributes
          DEFAULT_SIZE = 1

          def initialize(
            name: nil,
            key: nil,
            value: nil,
            size: nil,
            omitted: false,
            validator:
          )
            @name = name
            @key = key
            @value = value
            @size = size
            @omitted = omitted
            @validator = validator
          end

          def omitted?(context:)
            Utils.evaluate_callable(@omitted, context)
          end

          def compile(context:)
            size = Utils.evaluate_callable(@size, context)
            @validator.validate(name: @name, key: @key, size: size)
            size ||= [Column::Utils.calculate_size(@name), Column::Utils.calculate_size(@key)].max
            ::TableStructure::Schema::Columns::Attributes.new(
              name: @name,
              key: @key,
              value: @value,
              size: size
            )
          end
        end
      end
    end
  end
end
