# frozen_string_literal: true

module TableStructure
  module Schema
    module Column
      module Factory
        def self.create(name, definitions, context, options)
          Definition::Compiler
            .new(name, definitions, options)
            .compile(context)
            .map do |definition|
              if definition.is_a?(Hash)
                Attrs.new(**definition)
              else
                Schema.new(definition)
              end
            end
        end
      end
    end
  end
end
