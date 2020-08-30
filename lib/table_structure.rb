# frozen_string_literal: true

module TableStructure
  class Error < StandardError; end

  require 'table_structure/version'
  require 'forwardable'
  require 'table_structure/utils'
  require 'table_structure/schema'
  require 'table_structure/schema/class_methods'
  require 'table_structure/schema/composite_class'
  require 'table_structure/schema/column/utils'
  require 'table_structure/schema/dsl/column_builder'
  require 'table_structure/schema/dsl/column_definition'
  require 'table_structure/schema/dsl/context_builder'
  require 'table_structure/schema/dsl/row_builder'
  require 'table_structure/schema/definition/columns/compiler'
  require 'table_structure/schema/definition/columns/error'
  require 'table_structure/schema/definition/columns/validator'
  require 'table_structure/schema/definition/columns/attributes'
  require 'table_structure/schema/definition/columns/schema_class'
  require 'table_structure/schema/definition/columns/schema_instance'
  require 'table_structure/schema/column_builder_factory'
  require 'table_structure/schema/keys_builder'
  require 'table_structure/schema/row_context_builder_factory'
  require 'table_structure/schema/columns/attributes'
  require 'table_structure/schema/columns/schema'
  require 'table_structure/schema/utils'
  require 'table_structure/table'
  require 'table_structure/writer'
  require 'table_structure/csv/writer'
  require 'table_structure/iterator'
end
