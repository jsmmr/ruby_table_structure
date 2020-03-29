# 0.3.22
Changes:
- `TableStructure::Schema`
  - DSL
    - `column_converter`
      - Using `lambda` has been deprecated. Use `block` instead.
    - `context_builder`
      - Using `lambda` has been deprecated. Use `block` instead.

# 0.3.21
Changes:
- Add `TableStructure::Table`
  - This provides methods for converting data with the schema.
  - Use `TableStructure::Table.new` instead of `TableStructure::Schema#create_table`.
- `TableStructure::Schema`
  - `TableStructure::Schema#create_table` has been deprecated. Use `TableStructure::Table.new` instead.

# 0.3.20
Changes:
- `TableStructure::Schema`
  - Fix case where `context_builder` for `:table` do not apply.

# 0.3.19
Changes:
- `TableStructure::Writer`
  - `header_omitted: true` option has been deprecated. Use `header: false` option instead.
- `TableStructure::CSV::Writer`
  - `header_omitted: true` option has been deprecated. Use `header: false` option instead.
- `TableStructure::Iterator`
  - `header_omitted: true` option has been deprecated. Use `header: false` option instead.

# 0.3.18
Changes:
- Minor improvements.

# 0.3.17
Changes:
- `TableStructure::Schema`
  - `:row` option for `column_converter` DSL has been deprecated. Use `:body` option instead.
  - `:result_type` option of `create_table` method has been deprecated. Use `:row_type` option instead.
- `TableStructure::Schema::Table`
  - `rows` method has been deprecated. Use `body` method instead.
- `TableStructure::Writer`
  - `:result_type` option has been deprecated. Use `:row_type` option instead.
- `TableStructure::Iterator`
  - `:result_type` option has been deprecated. Use `:row_type` option instead.

# 0.3.16
Changes:
- `TableStructure::Schema`
  - Enable to add definitions in a block when initializing the schema.
  - Add `merge` class method.
  - Change `+` class method not to overwrite the definitions (`column_converter`, `context_builder`) by the last one with the same name. If you expect the same behavior as before, use `merge` instead.

# 0.3.15
Changes:
- `TableStructure::Schema`
  - Add `+` as class method. this method concatenates the schemas.

# 0.3.14
Changes:
- Support Ruby 2.7.

# 0.3.13
Changes:
- Minor improvements.

# 0.3.12
Changes:
- `TableStructure::Schema`
  - Fix `:name_prefix` and `:name_suffix` options so that they are applied after the column converters defined in the schema.

# 0.3.11
Changes:
- `TableStructure::CSV::Writer`
  - Add `:csv_options` option. This option's value is simply passed to `::CSV.new` as options'.

# 0.3.10
Changes:
- `TableStructure::Writer`
  - Fix an issue that objects with both `call` and` each` methods could not be enumerated.
- `TableStructure::CSV::Writer`
  - Fix `write` method's block to work.

# 0.3.9
Changes:
- Add `TableStructure::CSV::Writer`. This is a wrapper for `TableStructure::Writer`.

# 0.3.8
Changes:
- `TableStructure::Schema`
  - Add `:nil_definitions_ignored` option.
    - This defaults to `false`, which is same behavior as before.
    - If `true` is set, the column definitions evaluated to `nil` are ignored. this behaves like as if to define `omitted: true` in the column definition.

# 0.3.7
Changes:
- `TableStructure::Schema`
  - Improve performance when `result_type: :array` (default) option is set.
  - Improve performance when `column_converter` is not defined.

# 0.3.6
Changes:
- `TableStructure::Schema`
  - Improve performance when `context_builder` is not defined.

# 0.3.5
Changes:
- `TableStructure::Schema`
  - Add following options:
    - `:name_prefix`
    - `:name_suffix`
  - DSL
    - `column_converter`
      - Add `:header` and `:row` options.
        - If `header: false`, the converter is not applied to header values.
        - If `row: false`, the converter is not applied to body values.
        - Both options default to `true`, which is same behavior as before.

# 0.3.4
Changes:
- `TableStructure::Writer`
  - Fix broken `:result_type` option.
- `TableStructure::Iterator`
  - Fix broken `:result_type` option.

# 0.3.3
Changes:
- `TableStructure::Schema`
  - Improve designs and performance. You can ignore the following changes unless you have been using the schema instance method directly.
    - Add `TableStructure::Schema#create_table` method. It returns `TableStructure::Schema::Table` instance.
    - Remove `TableStructure::Schema#header` method. Use `TableStructure::Schema::Table#header` method instead.
    - Remove `TableStructure::Schema#row` method. Use `TableStructure::Schema::Table#row` method instead.

# 0.3.2
Changes:
- `TableStructure::Writer`
  - When `result_type: :hash` option is specified and `column(s)` `:key` of the schema is undefined, index number is used as the key.

# 0.3.1
Changes:
- `TableStructure::Writer`
  - Make `:result_type` option available.
- `TableStructure::Iterator`
  - Make `:result_type` option available.

# 0.3.0
Changes:
- `TableStructure::Schema`
  - Add following options:
    - `:key_prefix`
    - `:key_suffix`
  - DSL
    - `column(s)`
      - Add `:omitted` option.
      - Support nested schemas.

# 0.2.0
Changes:
- Add `TableStructure::Iterator`.

# 0.1.0
- First version
