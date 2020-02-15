# TableStructure

[![Build Status](https://travis-ci.org/jsmmr/ruby_table_structure.svg?branch=master)](https://travis-ci.org/jsmmr/ruby_table_structure)

- `TableStructure::Schema`
  - Defines columns of a table using DSL.
- `TableStructure::Writer`
  - Converts data with the schema, and outputs table structured data.
- `TableStructure::Iterator`
  - Converts data with the schema, and enumerates table structured data.

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

Define a schema:
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
```

Initialize the schema:
```ruby
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

Initialize a writer with the schema:
```ruby
writer = TableStructure::Writer.new(schema)
## To omit header, write:
# writer = TableStructure::Writer.new(schema, header_omitted: true)
```

Writes the items converted by the schema to array:
```ruby
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

## To use Rails `find_each` method, write:
# items = Item.enum_for(:find_each)
## or
# items = Enumerator.new { |y| Item.find_each { |item| y << item } }

table = []
writer.write(items, to: table)

# table
# => [["ID", "Name", "Pet 1", "Pet 2", "Pet 3", "Q1", "Q2", "Q3"], ["1", "Taro", "🐱", "🐶", "", "⭕️", "❌", "⭕️"], ["2", "Hanako", "🐇", "🐢", "🐿", "⭕️", "⭕️", "❌"]]
```

Writes the items converted by the schema to file as CSV:
```ruby
File.open('sample.csv', 'w') do |f|
  writer.write(items, to: CSV.new(f))
end
```

Writes the items converted by the schema to stream as CSV with Rails:
```ruby
# response.headers['X-Accel-Buffering'] = 'no' # Required if Nginx is used for reverse proxy
response.headers['Cache-Control'] = 'no-cache'
response.headers['Content-Type'] = 'text/csv'
response.headers['Content-Disposition'] = 'attachment; filename="sample.csv"'
response_body = Enumerator.new do |y|
  # y << "\uFEFF" # BOM (Prevent garbled characters for Excel)
  writer.write(items, to: CSV.new(y))
end
```
[Sample with docker](https://github.com/jsmmr/ruby_table_structure_sample)

You can also convert CSV character code:
```ruby
File.open('sample.csv', 'w') do |f|
  writer.write(items, to: CSV.new(f)) do |row_values|
    row_values.map { |val| val.to_s.encode('Shift_JIS', invalid: :replace, undef: :replace) }
  end
end
```

You can also use `TableStructure::CSV::Writer` instead:
```ruby
writer = TableStructure::CSV::Writer.new(schema)
File.open('sample.csv', 'w') do |f|
  writer.write(items, to: f, bom: true)
end
```

#### TableStructure::Iterator
Specifying `row_type: :hash` option works well.
To use this option, define `column(s)` with `:key`.

Define a schema:
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

  ## If the schemas are nested, :key must be unique in parent and child schemas.
  ## This can also be avoided by specifying :key_prefix or :key_suffix option.
  # columns ->(table) { NestedTableSchema.new(context: table, key_prefix: 'foo_', key_suffix: '_bar') }
end
```

Initialize a iterator with the schema:
```ruby
context = {
  questions: [
    { id: 'Q1', text: 'Do you like sushi?' },
    { id: 'Q2', text: 'Do you like yakiniku?' },
    { id: 'Q3', text: 'Do you like ramen?' }
  ]
}

schema = SampleTableSchema.new(context: context)
iterator = TableStructure::Iterator.new(schema, row_type: :hash, header_omitted: true)
```

Enumerate the items converted by the schema:
```ruby
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
# => [{:id=>1, :name=>"Taro", :pet1=>"🐱", :pet2=>"🐶", :pet3=>nil, :q1=>"⭕️", :q2=>"❌", :q3=>"⭕️"}, {:id=>2, :name=>"Hanako", :pet1=>"🐇", :pet2=>"🐢", :pet3=>"🐿", :q1=>"⭕️", :q2=>"⭕️", :q3=>"❌"}]

enum.lazy.select { |item| item[:q1] == '⭕️' }.take(1).force
# => [{:id=>1, :name=>"Taro", :pet1=>"🐱", :pet2=>"🐶", :pet3=>nil, :q1=>"⭕️", :q2=>"❌", :q3=>"⭕️"}]
```

### Advanced

You can add definitions when initializing the schema.
```ruby
class UserTableSchema
  include TableStructure::Schema

  column  name: 'ID',
          value: ->(row, *) { row[:id] }

  column  name: 'Name',
          value: ->(row, *) { row[:name] }
end

schema = UserTableSchema.new do
  column_converter :to_s, ->(val, *) { val.to_s }
end
```

You can also omit columns by defining `:omitted`.
```ruby
class UserTableSchema
  include TableStructure::Schema

  column  name: 'ID',
          value: ->(row, *) { row[:id] }

  column  name: 'Name',
          value: ->(row, *) { row[:name] }

  column  name: 'Secret',
          value: ->(row, *) { row[:secret] },
          omitted: ->(table) { !table[:admin] }
end

context = { admin: true }

schema = UserTableSchema.new(context: context)
```

You can also omit columns by specifying `nil_definitions_ignored: true`.
If this option is set to `true` and `column(s)` difinition returns `nil`, the difinition is ignored.
```ruby
class SampleTableSchema
  include TableStructure::Schema

  column  name: 'ID',
          value: ->(row, *) { row[:id] }

  column  name: 'Name',
          value: ->(row, *) { row[:name] }

  columns ->(table) {
    if table[:pet_num].positive?
      {
        name: (1..table[:pet_num]).map { |num| "Pet #{num}" },
        value: ->(row, *) { row[:pets] }
      }
    end
  }
end

context = { pet_num: 0 }

schema = SampleTableSchema.new(context: context, nil_definitions_ignored: true)
```

You can also nest the schemas.
```ruby
class UserTableSchema
  include TableStructure::Schema

  column  name: 'ID',
          value: ->(row, *) { row[:id] }

  column  name: 'Name',
          value: ->(row, *) { row[:name] }
end

class PetTableSchema
  include TableStructure::Schema

  columns name: ['Pet 1', 'Pet 2', 'Pet 3'],
          value: ->(row, *) { row[:pets] }
end

class QuestionTableSchema
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

  columns ->(table) { UserTableSchema.new(context: table) }
  ## or
  # columns UserTableSchema

  columns ->(table) { PetTableSchema.new(context: table) }
  ## or
  # columns PetTableSchema

  columns ->(table) { QuestionTableSchema.new(context: table) }
  ## or
  # columns QuestionTableSchema
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

You can also concatenate or merge the schema classes.
Both create a schema class, with a few differences.
- `+`
  - Similar to nesting the schemas.
    `column_converter` or `context_builder` works only to columns in the schema that they was defined.
- `merge`
  - If there are some definitions of `column_converter` or `context_builder` with the same name in the schemas to be merged, the one in the schema that is merged last will work to all columns.

```ruby
class UserTableSchema
  include TableStructure::Schema

  column  name: 'ID',
          value: ->(row, *) { row[:id] }

  column  name: 'Name',
          value: ->(row, *) { row[:name] }
end

class PetTableSchema
  include TableStructure::Schema

  columns name: ['Pet 1', 'Pet 2', 'Pet 3'],
          value: ->(row, *) { row[:pets] }

  column_converter :same_name, ->(val, *) { "pet: #{val}" }
end

class QuestionTableSchema
  include TableStructure::Schema

  columns ->(table) {
    table[:questions].map do |question|
      {
        name: question[:id],
        value: ->(row, *) { row[:answers][question[:id]] }
      }
    end
  }

  column_converter :same_name, ->(val, *) { "question: #{val}" }
end

context = {
  questions: [
    { id: 'Q1', text: 'Do you like sushi?' },
    { id: 'Q2', text: 'Do you like yakiniku?' },
    { id: 'Q3', text: 'Do you like ramen?' }
  ]
}

concatenated_schema = (UserTableSchema + PetTableSchema + QuestionTableSchema).new(context: context)

merged_schema = UserTableSchema.merge(PetTableSchema, QuestionTableSchema).new(context: context)
```

You can also use `context_builder`.
This may be useful if `column(s)` lambda is complicated.
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
end
```

You can also use only `TableStructure::Schema` instance.
```erb
<% @schema.create_table(row_type: :array) do |table| %>
  <table>
    <thead>
      <tr>
        <% table.header.each do |val| %>
          <th><%= val %></th>
        <% end %>
      </tr>
    </thead>

    <tbody>
      <% table.body(@items).each do |row| %>
        <tr>
          <% row.each do |val| %>
            <td><%= val %></td>
          <% end %>
        </tr>
      <% end %>
    </tbody>
  </table>
<% end %>
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jsmmr/ruby_table_structure.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
