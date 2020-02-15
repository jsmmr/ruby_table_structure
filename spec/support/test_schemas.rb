# frozen_string_literal: true

module Mono
  class TestTableSchema
    include TableStructure::Schema

    column  name: 'ID',
            value: ->(row, _table) { row[:id] }

    column  name: 'Name',
            value: ->(row, *) { row[:name] }

    columns name: ['Pet 1', 'Pet 2', 'Pet 3'],
            value: ->(row, *) { row[:pets] }

    columns lambda { |table|
      table[:questions].map do |question|
        {
          name: question[:id],
          value: ->(row, *) { row[:answers][question[:id]] }
        }
      end
    }
  end

  module WithKeys
    class TestTableSchema
      include TableStructure::Schema

      column  name: 'ID',
              key: :id,
              value: ->(row, *) { row[:id] }

      column  name: 'Name',
              key: :name,
              value: ->(row, *) { row[:name] }

      columns name: ['Pet 1', 'Pet 2', 'Pet 3'],
              key: %i[pet1 pet2 pet3],
              value: ->(row, *) { row[:pets] }

      columns lambda { |table|
        table[:questions].map do |question|
          {
            name: question[:id],
            key: question[:id].downcase.to_sym,
            value: ->(row, *) { row[:answers][question[:id]] }
          }
        end
      }
    end
  end
end

module Micro
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

    columns lambda { |table|
      table[:questions].map do |question|
        {
          name: question[:id],
          value: ->(row, *) { row[:answers][question[:id]] }
        }
      end
    }
  end

  module Nested
    class TestTableSchema
      include TableStructure::Schema

      columns UserTableSchema

      columns PetTableSchema

      columns QuestionTableSchema
    end
  end

  module Concatenated
    TestTableSchema =
      [
        UserTableSchema,
        PetTableSchema,
        QuestionTableSchema
      ]
      .reduce(&:+)
  end

  module Merged
    TestTableSchema =
      UserTableSchema
      .merge(
        PetTableSchema,
        QuestionTableSchema
      )
  end
end
