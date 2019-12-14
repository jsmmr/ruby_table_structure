# frozen_string_literal: true

module TableStructure
  module Schema
    module DSL
      module Option
        def option(name, value)
          warn "[TableStructure] The use of `option` DSL has been deprecated. #{caller_locations(1, 1)}"
          options[name] = value
          nil
        end

        def options
          @table_structure_schema_options__ ||= {}
        end
      end
    end
  end
end
