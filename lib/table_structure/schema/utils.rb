# frozen_string_literal: true

module TableStructure
  module Schema
    module Utils
      def self.evaluate_callable(val, *params)
        val.respond_to?(:call) ? val.call(*params) : val
      end
    end
  end
end
