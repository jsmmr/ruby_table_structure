# 0.3.8
Changes:
- `TableStructure::Schema`
  - Add `:nil_definitions_ignored` option.
    - This defaults to `false`, which is same behavior as before.
    - If `true` is set, ignore the column definitions evaluated to `nil`. this behaves like as if to define `omitted: true` in the column definition.

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
        - If `row: false`, the converter is not applied to row values.
        - Both options default to `true`, which is same behavior as before.

# 0.3.4
Changes:
- `TableStructure::Writer`
  - Fix broken `:result_type` option.
- `TableStructure::Iterator`
  - Fix broken `:result_type` option. (Passed to the writer internally.)

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
  - Make `:result_type` option available. (Passed to the writer internally.)
- `TableStructure::Schema`
  - `:result_type` option is deprecated.

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
