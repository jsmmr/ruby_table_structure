# frozen_string_literal: true

module TableStructure
  module Schema
    module RowBuilder
      DEFAULT_ROW_BUILDERS = {
        _to_hash_: Definition::RowBuilder.new(
          lambda { |values, keys, *|
            keys.map.with_index { |key, i| [key || i, values[i]] }.to_h
          },
          enabled_row_types: [:hash]
        )
      }.freeze

      class << self
        def prepend_default_builders(builders)
          DEFAULT_ROW_BUILDERS.merge(builders)
        end
      end
    end
  end
end
