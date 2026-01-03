# TableStructure

[![build](https://github.com/jsmmr/ruby_table_structure/actions/workflows/build.yml/badge.svg)](https://github.com/jsmmr/ruby_table_structure/actions/workflows/build.yml)
[![CodeQL](https://github.com/jsmmr/ruby_table_structure/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/jsmmr/ruby_table_structure/actions/workflows/codeql-analysis.yml)

Build **complex table schemas** with a **declarative DSL**. Export data as arrays, hashes, or stream to CSV with support for dynamic columns and schema composition.

- `TableStructure::Schema`
  - Define table columns using DSL.
- `TableStructure::Writer`
  - Convert data with the schema and output table-structured data.
- `TableStructure::Iterator`
  - Convert data with the schema and enumerate table-structured data.
- `TableStructure::Table`
  - Provide methods for converting data with the schema.

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

  column  name: ['Pet 1', 'Pet 2', 'Pet 3'],
          value: ->(row, *) { row[:pets] }

  columns do |table|
    table[:questions].map do |question|
      {
        name: question[:id],
        value: ->(row, *) { row[:answers][question[:id]] }
      }
    end
  end

  column_builder :to_s do |val, _row, _table|
    val.to_s
  end
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
# writer = TableStructure::Writer.new(schema, header: false)
```

Write the items converted by the schema to array:
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

array = []
writer.write(items, to: array)

# array
# => [["ID", "Name", "Pet 1", "Pet 2", "Pet 3", "Q1", "Q2", "Q3"], ["1", "Taro", "🐱", "🐶", "", "⭕️", "❌", "⭕️"], ["2", "Hanako", "🐇", "🐢", "🐿", "⭕️", "⭕️", "❌"]]
```

Write the items converted by the schema to file as CSV:
```ruby
File.open('sample.csv', 'w') do |f|
  writer.write(items, to: CSV.new(f))
end
```

Write the items converted by the schema to stream as CSV with Rails:
```ruby
# response.headers['X-Accel-Buffering'] = 'no' # Required if Nginx is used for reverse proxy
response.headers['Cache-Control'] = 'no-cache'
response.headers['Content-Type'] = 'text/csv'
response.headers['Content-Disposition'] = 'attachment; filename="sample.csv"'
response.headers['Last-Modified'] = Time.now.ctime.to_s # Required if Rack >= 2.2.0
response_body = Enumerator.new do |y|
  # y << "\uFEFF" # BOM (Prevent garbled characters for Excel)
  writer.write(items, to: CSV.new(y))
end
```

You can also convert CSV character code:
```ruby
File.open('sample.csv', 'w') do |f|
  writer.write(items, to: CSV.new(f)) do |row|
    row.map { |val| val.to_s.encode('Shift_JIS', invalid: :replace, undef: :replace) }
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
If you want to convert the item to row as Hash instead of Array, specify `row_type: :hash`.
To use this option, define `:key` on `column(s)`.

Define a schema:
```ruby
class SampleTableSchema
  include TableStructure::Schema

  column  name: 'ID',
          key: :id,
          value: ->(row, *) { row[:id] }

  column  name: 'Name',
          key: :name,
          value: ->(row, *) { row[:name] }

  column  name: ['Pet 1', 'Pet 2', 'Pet 3'],
          key: %i[pet1 pet2 pet3],
          value: ->(row, *) { row[:pets] }

  columns do |table|
    table[:questions].map do |question|
      {
        name: question[:id],
        key: question[:id].downcase.to_sym,
        value: ->(row, *) { row[:answers][question[:id]] }
      }
    end
  end
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
iterator = TableStructure::Iterator.new(schema, header: false, row_type: :hash)
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

#### TableStructure::Table

Initialize a table with the schema and render the table:
```erb
<% TableStructure::Table.new(schema, row_type: :hash) do |table| %>
  <table>
    <thead>
      <tr>
        <% table.header.each do |key, value| %>
          <th class="<%= key %>"><%= value %></th>
        <% end %>
      </tr>
    </thead>

    <tbody>
      <% table.body(@items).each do |row| %>
        <tr>
          <% row.each do |key, value| %>
            <td class="<%= key %>"><%= value %></td>
          <% end %>
        </tr>
      <% end %>
    </tbody>
  </table>
<% end %>
```

### Sample with docker

https://github.com/jsmmr/ruby_table_structure_sample

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
  column_builder :to_s do |val|
    val.to_s
  end
end
```

You can also omit columns by using `:omitted`.
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

You can also omit columns by using `:nil_definitions_ignored` option.
If this option is set to `true` and `column(s)` definition returns `nil`, the definition is ignored.
```ruby
class SampleTableSchema
  include TableStructure::Schema

  column  name: 'ID',
          value: ->(row, *) { row[:id] }

  column  name: 'Name',
          value: ->(row, *) { row[:name] }

  columns do |table|
    if table[:pet_num].positive?
      {
        name: (1..table[:pet_num]).map { |num| "Pet #{num}" },
        value: ->(row, *) { row[:pets] }
      }
    end
  end
end

context = { pet_num: 0 }

schema = SampleTableSchema.new(context: context, nil_definitions_ignored: true)
```

You can also use `context_builder` to change the context object that the `lambda` receives.
```ruby
class SampleTableSchema
  include TableStructure::Schema

  TableContext = Struct.new(:questions, keyword_init: true)

  RowContext = Struct.new(:id, :name, :pets, :answers, keyword_init: true) do
    def increase_pets
      pets + pets
    end
  end

  context_builder :table do |context|
    TableContext.new(**context)
  end

  context_builder :row do |context|
    RowContext.new(**context)
  end

  column  name: 'ID',
          value: ->(row, *) { row.id }

  column  name: 'Name',
          value: ->(row, *) { row.name }

  column  name: ['Pet 1', 'Pet 2', 'Pet 3'],
          value: ->(row, *) { row.increase_pets }

  columns do |table|
    table.questions.map do |question|
      {
        name: question[:id],
        value: ->(row, *) { row.answers[question[:id]] }
      }
    end
  end
end
```

You can also nest the schemas.
If you nest the schemas and use `row_type: :hash`, `:key` must be unique in the schemas.
You can also use `:key_prefix` or `:key_suffix` option to keep uniqueness of the keys.

```ruby
class UserTableSchema
  include TableStructure::Schema

  column  name: 'ID',
          key: :id,
          value: ->(row, *) { row[:id] }

  column  name: 'Name',
          key: :name,
          value: ->(row, *) { row[:name] }
end

class SampleTableSchema
  include TableStructure::Schema

  columns UserTableSchema

  columns do |table|
    UserTableSchema.new(context: table, name_prefix: 'Friend ', key_prefix: 'friend_') do
      context_builder :row do |context|
        context[:friend]
      end
    end
  end
end

items = [
  {
    id: 1,
    name: 'Taro',
    friend: {
      id: 2,
      name: 'Hanako'
    }
  }
]

schema = SampleTableSchema.new(context: {})
TableStructure::Iterator.new(schema, row_type: :hash).iterate(items)
```

You can also concatenate or merge the schema classes.
Both create a schema class, with a few differences.
- `+`
  - Similar to nesting the schemas.
    `column_builder` works only to columns in the schema that they was defined.
- `merge`
  - If there are some definitions of `column_builder` with the same name in the schemas to be merged, the one in the schema that is merged last will work to all columns.

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

  column  name: ['Pet 1', 'Pet 2', 'Pet 3'],
          value: ->(row, *) { row[:pets] }

  column_builder :same_name do |val|
    "pet: #{val}"
  end
end

class QuestionTableSchema
  include TableStructure::Schema

  columns do |table|
    table[:questions].map do |question|
      {
        name: question[:id],
        value: ->(row, *) { row[:answers][question[:id]] }
      }
    end
  end

  column_builder :same_name do |val|
    "question: #{val}"
  end
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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jsmmr/ruby_table_structure.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
