# frozen_string_literal: true

module TableStructure
  module Schema
    module Definition
      module Columns
        class Compiler
          def initialize(schema_name, definitions, options)
            @schema_name = schema_name
            @definitions = definitions
            @options = options
          end

          def compile(context = nil)
            @definitions
              .map { |definition| Utils.evaluate_callable(definition, context) }
              .map.with_index do |definitions, i|
                validator = Validator.new(@schema_name, i)

                [definitions]
                  .flatten
                  .map do |definition|
                    if definition.is_a?(Hash)
                      Attributes.new(**definition, validator: validator)
                    elsif Utils.schema_instance?(definition)
                      SchemaInstance.new(definition)
                    elsif Utils.schema_class?(definition)
                      SchemaClass.new(definition)
                    elsif definition.nil? && @options[:nil_definitions_ignored]
                      next
                    else
                      raise Error.new('Invalid definition.', @schema_name, i)
                    end
                  end
              end
              .flatten
              .compact
              .reject { |column| column.omitted?(context: context) }
              .map { |column| column.compile(context: context) }
          end
        end
      end
    end
  end
end
