# frozen_string_literal: true

module TableStructure
  module Schema
    class Table
      class ContextBuilder < Module
        def initialize(overrides)
          overrides
            .reject { |callable:, **| callable.nil? }
            .each do |method:, callable:|
              define_method(method) do |context: nil|
                super(context: callable.call(context))
              end
            end
        end
      end
    end
  end
end
