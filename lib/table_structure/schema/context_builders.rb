# frozen_string_literal: true

module TableStructure
  module Schema
    class ContextBuilders
      def initialize(builders)
        @table_builder = builders[:table]
        @header_builder = builders[:header]
        @row_builder = builders[:row]
      end

      def build_for_table(context)
        if @table_builder
          @table_builder.call(context)
        else
          context
        end
      end

      def extend_methods_for(table)
        methods = {}

        if table.send(:contain_callable?, :name)
          methods[:header] = create_method(@header_builder)
        end
        if table.send(:contain_callable?, :value)
          methods[:data] = create_method(@row_builder)
        end

        methods.reject! { |_k, v| v.nil? }
        return if methods.empty?

        table.extend ContextBuildable.new(methods)
      end

      private

      def create_method(builder)
        return if builder.nil?

        proc do |context: nil|
          super(context: builder.call(context))
        end
      end
    end

    class ContextBuildable < Module
      def initialize(methods)
        methods.each do |name, method|
          define_method(name, &method)
        end
      end
    end
  end
end
