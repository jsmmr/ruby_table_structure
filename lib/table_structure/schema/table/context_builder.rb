# frozen_string_literal: true

module TableStructure
  module Schema
    class Table
      class ContextBuilder < Module
        def initialize(name, callable)
          @available = !callable.nil?

          return unless @available

          define_method(name) do |context: nil|
            super(context: callable.call(context))
          end
        end

        def available?
          @available
        end
      end
    end
  end
end
