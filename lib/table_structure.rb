# frozen_string_literal: true

module TableStructure
  class Error < StandardError; end

  require 'table_structure/version'

  require 'table_structure/schema'
  require 'table_structure/schema/dsl/column_converter'
  require 'table_structure/schema/dsl/column_definition'
  require 'table_structure/schema/dsl/context_builder'
  require 'table_structure/schema/dsl/result_builder'
  require 'table_structure/schema/definition'
  require 'table_structure/schema/definition/error'
  require 'table_structure/schema/definition/validator'
  require 'table_structure/schema/table'
  require 'table_structure/schema/column'
  require 'table_structure/schema/utils'
  require 'table_structure/writer'
end
