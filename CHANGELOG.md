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
  - When `result_type: :hash` option is specified and `column(s)` key of the schema is undefined, index number is used as the key.

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
  - Add `:omitted` key for `column(s)` DSL.
  - Support nested schema.
  - Add following options for schema initialization:
    - `:key_prefix`
    - `:key_suffix`

# 0.2.0
Changes:
- Add `TableStructure::Iterator`.

# 0.1.0
- First version
