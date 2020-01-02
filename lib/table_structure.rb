# frozen_string_literal: true

module TableStructure
  class Error < StandardError; end

  require 'table_structure/version'
  require 'forwardable'
  require 'table_structure/schema'
  require 'table_structure/schema/class_methods'
  require 'table_structure/schema/dsl/column_converter'
  require 'table_structure/schema/dsl/column_definition'
  require 'table_structure/schema/dsl/context_builder'
  require 'table_structure/schema/dsl/option'
  require 'table_structure/schema/dsl/result_builder'
  require 'table_structure/schema/column_converter'
  require 'table_structure/schema/column_converters'
  require 'table_structure/schema/context_builder'
  require 'table_structure/schema/context_builders'
  require 'table_structure/schema/result_builders'
  require 'table_structure/schema/table'
  require 'table_structure/schema/table/key_decorator'
  require 'table_structure/schema/column/attrs'
  require 'table_structure/schema/column/schema'
  require 'table_structure/schema/column/factory'
  require 'table_structure/schema/column/definition/compiler'
  require 'table_structure/schema/column/definition/error'
  require 'table_structure/schema/column/definition/validator'
  require 'table_structure/schema/utils'
  require 'table_structure/writer'
  require 'table_structure/csv/writer'
  require 'table_structure/iterator'
end
