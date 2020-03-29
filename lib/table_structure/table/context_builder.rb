# frozen_string_literal: true

module TableStructure
  class Table::ContextBuilder
    class ContextBuildable < Module
      def initialize(methods)
        methods.each do |name, method|
          define_method(name, &method)
        end
      end
    end

    class << self
      def create_module(
        builders,
        apply_to_name: true,
        apply_to_value: true,
        context:
      )
        return if builders.empty?

        header_builder = builders[:header] # TODO: Change not to use keyword of `header`
        row_builder = builders[:row]

        methods = {}

        if apply_to_name && builders.key?(:header)
          methods[:header] = create_method(builders[:header])
        end

        if apply_to_value && builders.key?(:row)
          methods[:data] = create_method(builders[:row])
        end

        yield ContextBuildable.new(methods)
      end

      private

      def create_method(builder)
        return if builder.nil?

        proc do |context: nil|
          super(context: builder.call(context))
        end
      end
    end
  end
end
