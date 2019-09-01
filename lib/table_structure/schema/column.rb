# frozen_string_literal: true

module TableStructure
  module Schema
    module Column
      def self.create(definition, indexer, options)
        if definition.is_a?(Hash)
          Attrs.new(definition, indexer, options)
        else
          Schema.new(definition, indexer)
        end
      end
    end
  end
end
