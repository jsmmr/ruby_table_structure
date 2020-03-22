# frozen_string_literal: true

module TableStructure
  module Schema
    module ColumnConverter
      class << self
        def create_optional_converters(
          name_prefix: nil,
          name_suffix: nil
        )
          column_converters = {}

          if name_prefix
            column_converters[:_name_prepender_] =
              create_prepender(name_prefix, header: true, body: false)
          end

          if name_suffix
            column_converters[:_name_appender_] =
              create_appender(name_suffix, header: true, body: false)
          end

          column_converters
        end

        private

        def create_prepender(string, **options)
          Definition::ColumnConverter.new(
            **options
          ) do |val, *|
            val.nil? ? val : "#{string}#{val}"
          end
        end

        def create_appender(string, **options)
          Definition::ColumnConverter.new(
            **options
          ) do |val, *|
            val.nil? ? val : "#{val}#{string}"
          end
        end
      end
    end
  end
end
