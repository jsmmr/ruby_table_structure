# frozen_string_literal: true

module TableStructure
  module Schema
    module Column
      def self.create(definition, options)
        if definition.is_a?(Hash)
          Attrs.new(definition, options)
        else
          Schema.new(definition)
        end
      end
    end
  end
end
