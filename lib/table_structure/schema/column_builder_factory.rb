# frozen_string_literal: true

module TableStructure
  module Schema
    class ColumnBuilderFactory
      def initialize(
        builders,
        context: nil,
        name_prefix: nil,
        name_suffix: nil
      )
        @builders = builders
        @context = context

        optional_builders = {}

        if name_prefix
          optional_builders[:_name_prepender_] =
            ::TableStructure::Utils::TypedProc.new(
              types: :header
            ) do |val, *|
              val.nil? ? val : "#{name_prefix}#{val}"
            end
        end

        if name_suffix
          optional_builders[:_name_appender_] =
            ::TableStructure::Utils::TypedProc.new(
              types: :header
            ) do |val, *|
              val.nil? ? val : "#{val}#{name_suffix}"
            end
        end

        @builders.merge!(optional_builders) unless optional_builders.empty?
      end

      def create_header_builder
        builders =
          @builders
          .select { |_k, v| v.typed?(:header) }
          .values

        return if builders.empty?

        proc do |row|
          row.values = row.values.map do |value|
            builders.reduce(value) do |value, builder|
              builder.call(value, row.context, @context)
            end
          end
          row
        end
      end

      def create_data_builder
        builders =
          @builders
          .select { |_k, v| v.typed?(:body) }
          .values

        return if builders.empty?

        proc do |row|
          row.values = row.values.map do |value|
            builders.reduce(value) do |value, builder|
              builder.call(value, row.context, @context)
            end
          end
          row
        end
      end
    end
  end
end
