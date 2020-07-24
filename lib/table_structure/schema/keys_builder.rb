# frozen_string_literal: true

module TableStructure
  module Schema
    class KeysBuilder
      def initialize(prefix: nil, suffix: nil)
        @prefix = prefix
        @suffix = suffix
      end

      def build(keys)
        return keys unless has_any_options?

        keys.map do |key|
          next key unless key

          decorated_key = "#{@prefix}#{key}#{@suffix}"
          key.is_a?(Symbol) ? decorated_key.to_sym : decorated_key
        end
      end

      private

      def has_any_options?
        @prefix || @suffix
      end
    end
  end
end
