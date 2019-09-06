# TableStructure

[![Build Status](https://travis-ci.org/jsmmr/ruby_table_structure.svg?branch=master)](https://travis-ci.org/jsmmr/ruby_table_structure)

`TableStructure` has two major functions.
The functions are `TableStructure::Schema` that defines the schema of a table using DSL and ` TableStructure::Writer` that converts and outputs data with the schema.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'table_structure'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install table_structure

## Usage

### Basic

#### TableStructure::Schema
```ruby
class SampleTableSchema
  include TableStructure::Schema

  column  name: 'ID',
          value: ->(row, _table) { row[:id] }

  column  name: 'Name',
          value: ->(row, *) { row[:name] }

  columns name: ['Pet 1', 'Pet 2', 'Pet 3'],
          value: ->(row, *) { row[:pets] }

  columns ->(table) {
    table[:questions].map do |question|
      {
        name: question[:id],
        value: ->(row, *) { row[:answers][question[:id]] }
      }
    end
  }

  column_converter :to_s, ->(val, _row, _table) { val.to_s }
end

context = {
  questions: [
    { id: 'Q1', text: 'Do you like sushi?' },
    { id: 'Q2', text: 'Do you like yakiniku?' },
    { id: 'Q3', text: 'Do you like ramen?' }
  ]
}

schema = SampleTableSchema.new(context: context)
```

#### TableStructure::Writer
```ruby
writer = TableStructure::Writer.new(schema)
## When omitting header line
# writer = TableStructure::Writer.new(schema, header_omitted: true)

items = [
  {
    id: 1,
    name: 'Taro',
    pets: ['🐱', '🐶'],
    answers: { 'Q1' => '⭕️', 'Q2' => '❌', 'Q3' => '⭕️' }
  },
  {
    id: 2,
    name: 'Hanako',
    pets: ['🐇', '🐢', '🐿', '🦒'],
    answers: { 'Q1' => '⭕️', 'Q2' => '⭕️', 'Q3' => '❌' }
  }
]

## When using `find_each` method of Rails
# items = ->(y) { Records.find_each {|r| y << r } }

# Output to array
table = []
writer.write(items, to: table)

# table
# => [["ID", "Name", "Pet 1", "Pet 2", "Pet 3", "Q1", "Q2", "Q3"], ["1", "Taro", "🐱", "🐶", "", "⭕️", "❌", "⭕️"], ["2", "Hanako", "🐇", "🐢", "🐿", "⭕️", "⭕️", "❌"]]

# Output to file as CSV
File.open('sample.csv', 'w') do |f|
  writer.write(items, to: CSV.new(f))
end

# Output to stream as CSV with Rails
response.headers['X-Accel-Buffering'] = 'no' # When using Nginx for reverse proxy
response.headers['Cache-Control'] = 'no-cache'
response.headers['Content-Type'] = 'text/csv'
response.headers['Content-Disposition'] = 'attachment; filename="sample.csv"'
response_body = Enumerator.new { |y| writer.write(items, to: CSV.new(y)) }
```

#### TableStructure::Iterator
Specifying `result_type: :hash` option works well.
To use this option, define `column(s)` with `:key`.
```ruby
class SampleTableSchema
  include TableStructure::Schema

  # If header is required, :name must also be defined.
  column  key: :id,
          value: ->(row, *) { row[:id] }

  column  key: :name,
          value: ->(row, *) { row[:name] }

  columns key: %i[pet1 pet2 pet3],
          value: ->(row, *) { row[:pets] }

  columns ->(table) {
    table[:questions].map do |question|
      {
        key: question[:id].downcase.to_sym,
        value: ->(row, *) { row[:answers][question[:id]] }
      }
    end
  }

  ## When nesting schemas, same key must not exist in parent and child schemas.
  ## This can also be avoided by specifying :key_prefix or :key_suffix option.
  # columns ->(table) { NestedSchema.new(context: table, key_prefix: 'foo_', key_suffix: '_bar') }

  column_converter :to_s, ->(val, *) { val.to_s }
end

context = {
  questions: [
    { id: 'Q1', text: 'Do you like sushi?' },
    { id: 'Q2', text: 'Do you like yakiniku?' },
    { id: 'Q3', text: 'Do you like ramen?' }
  ]
}

schema = SampleTableSchema.new(context: context)
iterator = TableStructure::Iterator.new(schema, result_type: :hash, header_omitted: true)
## or
# writer = TableStructure::Writer.new(schema, result_type: :hash, header_omitted: true)
# iterator = TableStructure::Iterator.new(writer)

items = [
  {
    id: 1,
    name: 'Taro',
    pets: ['🐱', '🐶'],
    answers: { 'Q1' => '⭕️', 'Q2' => '❌', 'Q3' => '⭕️' }
  },
  {
    id: 2,
    name: 'Hanako',
    pets: ['🐇', '🐢', '🐿', '🦒'],
    answers: { 'Q1' => '⭕️', 'Q2' => '⭕️', 'Q3' => '❌' }
  }
]

enum = iterator.iterate(items)

## Enumerator methods is available
enum.each do |item|
  # ...
end

enum.map(&:itself)
# => [{:id=>"1", :name=>"Taro", :pet1=>"🐱", :pet2=>"🐶", :pet3=>"", :q1=>"⭕️", :q2=>"❌", :q3=>"⭕️"}, {:id=>"2", :name=>"Hanako", :pet1=>"🐇", :pet2=>"🐢", :pet3=>"🐿", :q1=>"⭕️", :q2=>"⭕️", :q3=>"❌"}]

enum.lazy.select { |item| item[:q1] == '⭕️' }.take(1).force
# => [{:id=>"1", :name=>"Taro", :pet1=>"🐱", :pet2=>"🐶", :pet3=>"", :q1=>"⭕️", :q2=>"❌", :q3=>"⭕️"}]
```

### Advanced

You can also omit columns by defining `:omitted`.
```ruby
class SampleTableSchema
  include TableStructure::Schema

  column  name: 'ID',
          value: ->(row, _table) { row[:id] }

  column  name: 'Name',
          value: ->(row, *) { row[:name] }

  column  name: 'Secret',
          value: ->(row, *) { row[:secret] },
          omitted: ->(table) { !table[:admin] }
end

context = { admin: true }

schema = SampleTableSchema.new(context: context)
```

You can also nest schemas.
```ruby
class PetsSchema
  include TableStructure::Schema

  columns name: ['Pet 1', 'Pet 2', 'Pet 3'],
          value: ->(row, *) { row[:pets] }
end

class QuestionsSchema
  include TableStructure::Schema

  columns ->(table) {
    table[:questions].map do |question|
      {
        name: question[:id],
        value: ->(row, *) { row[:answers][question[:id]] }
      }
    end
  }
end

class SampleTableSchema
  include TableStructure::Schema

  column  name: 'ID',
          value: ->(row, _table) { row[:id] }

  column  name: 'Name',
          value: ->(row, *) { row[:name] }

  columns ->(table) { PetsSchema.new(context: table) }

  columns ->(table) { QuestionsSchema.new(context: table) }

  column_converter :to_s, ->(val, *) { val.to_s }
end

context = {
  questions: [
    { id: 'Q1', text: 'Do you like sushi?' },
    { id: 'Q2', text: 'Do you like yakiniku?' },
    { id: 'Q3', text: 'Do you like ramen?' }
  ]
}

schema = SampleTableSchema.new(context: context)
```

You can also use `context_builder`.
This may be useful when `column` definition lambda is complicated.
```ruby
class SampleTableSchema
  include TableStructure::Schema

  TableContext = Struct.new(:questions, keyword_init: true)

  RowContext = Struct.new(:id, :name, :pets, :answers, keyword_init: true) do
    def more_pets
      pets + pets
    end
  end

  context_builder :table, ->(context) { TableContext.new(**context) }
  context_builder :row, ->(context) { RowContext.new(**context) }

  column  name: 'ID',
          value: ->(row, *) { row.id }

  column  name: 'Name',
          value: ->(row, *) { row.name }

  columns name: ['Pet 1', 'Pet 2', 'Pet 3'],
          value: ->(row, *) { row.more_pets }

  columns ->(table) {
    table.questions.map do |question|
      {
        name: question[:id],
        value: ->(row, *) { row.answers[question[:id]] }
      }
    end
  }

  column_converter :to_s, ->(val, *) { val.to_s }
end
```

If you want to convert CSV character code, you can do so within block of `write` method.
```ruby
File.open('sample.csv', 'w') do |f|
  writer.write(items, to: CSV.new(f)) do |row_values|
    row_values.map { |val| val&.to_s&.encode('Shift_JIS', invalid: :replace, undef: :replace) }
  end
end
```

You can also use only `TableStructure::Schema`.
```ruby
schema = SampleTableSchema.new
table = schema.create_table
header = table.header
items.each do |item|
  row = table.row(context: item)
  ...
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jsmmr/ruby_table_structure.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
