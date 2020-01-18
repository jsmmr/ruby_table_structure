# frozen_string_literal: true

RSpec.describe TableStructure::Schema do
  let(:table) { schema.create_table }

  context 'when several `column` are defined' do
    module A
      class TestTableSchema
        include TableStructure::Schema

        column  name: 'ID',
                value: ->(row, *) { row[:id] }

        column  name: 'Name',
                value: ->(row, *) { row[:name] }
      end
    end

    let(:schema) { A::TestTableSchema.new }

    describe 'Table#header' do
      subject { table.header }

      it {
        is_expected.to eq [
          'ID',
          'Name',
        ]
      }
    end

    describe 'Table#row' do
      subject { table.row(context: item) }

      let(:item) do
        { id: 1, name: 'Taro' }
      end

      it {
        is_expected.to eq [
          1,
          'Taro',
        ]
      }
    end
  end

  context 'when several `columns` are defined' do
    module B
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
    end

    let(:context) do
      {
        questions: [
          { id: 'Q1', text: 'Do you like sushi?' },
          { id: 'Q2', text: 'Do you like yakiniku?' },
          { id: 'Q3', text: 'Do you like ramen?' }
        ]
      }
    end

    let(:schema) do
      B::TestTableSchema.new(context: context)
    end

    describe 'Table#header' do
      subject { table.header }

      it {
        is_expected.to eq [
          'ID',
          'Name',
          'Pet 1',
          'Pet 2',
          'Pet 3',
          'Q1',
          'Q2',
          'Q3'
        ]
      }
    end

    describe 'Table#row' do
      subject { table.row(context: item) }

      let(:item) do
        { id: 1, name: 'Taro', pets: %w[cat dog], answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' } }
      end

      it {
        is_expected.to eq [
          1,
          'Taro',
          'cat',
          'dog',
          nil,
          'yes',
          'no',
          'yes'
        ]
      }
    end
  end

  context 'when several `column_converter` are defined' do
    module C
      class TestTableSchema
        include TableStructure::Schema

        column  name: 'ID',
                value: ->(row, *) { row[:id] }

        column  name: 'Name',
                value: ->(row, *) { row[:name] }

        columns name: 'Pets',
                value: ->(row, *) { row[:pets] },
                size: 3

        columns lambda { |table|
          table[:questions].map do |question|
            {
              name: question[:id],
              value: ->(row, *) { row[:answers][question[:id]] }
            }
          end
        }

        column_converter :to_s, ->(val, *) { val.to_s }
        column_converter :empty_to_hyphen, ->(val, *) { val.empty? ? '-' : val }, header: true, row: true
      end
    end

    let(:context) do
      {
        questions: [
          { id: 'Q1', text: 'Do you like sushi?' },
          { id: 'Q2', text: 'Do you like yakiniku?' },
          { id: 'Q3', text: 'Do you like ramen?' }
        ]
      }
    end

    let(:schema) do
      C::TestTableSchema.new(context: context)
    end

    describe 'Table#header' do
      subject { table.header }

      it {
        is_expected.to eq [
          'ID',
          'Name',
          'Pets',
          '-',
          '-',
          'Q1',
          'Q2',
          'Q3'
        ]
      }
    end

    describe 'Table#row' do
      subject { table.row(context: item) }

      let(:item) do
        {
          id: 1,
          name: 'Taro',
          pets: %w[cat dog],
          answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' }
        }
      end

      it {
        is_expected.to eq [
          '1',
          'Taro',
          'cat',
          'dog',
          '-',
          'yes',
          'no',
          'yes'
        ]
      }
    end
  end

  context 'when `context_builder` is defined' do
    module D
      class TestTableSchema
        include TableStructure::Schema

        TableContext = Struct.new(:questions)

        HeaderContext = Struct.new(:id, :name, :pets, :questions)

        RowContext = Struct.new(:id, :name, :pets, :answers) do
          def more_pets
            pets + pets
          end
        end

        context_builder :table, ->(context) { TableContext.new(*context.values) }
        context_builder :header, ->(context) { HeaderContext.new(*context.values) }
        context_builder :row, ->(context) { RowContext.new(*context.values) }

        column  name: ->(header, *) { header.id },
                value: ->(row, _table) { row.id },
                size: 1

        column  name: ->(header, *) { header.name },
                value: ->(row, *) { row.name },
                size: 1

        columns name: ->(header, *) { header.pets },
                value: ->(row, *) { row.more_pets },
                size: 3

        columns lambda { |table|
          table.questions.map.with_index do |question, i|
            {
              name: ->(header, *) { header.questions[i] },
              value: ->(row, *) { row.answers[question[:id]] },
              size: 1
            }
          end
        }

        column_converter :nil_to_hyphen, ->(val, *) { val.nil? ? '-' : val }
        column_converter :to_s, ->(val, *) { val.to_s }
      end
    end

    let(:context) do
      {
        questions: [
          { id: 'Q1', text: 'Do you like sushi?' },
          { id: 'Q2', text: 'Do you like yakiniku?' },
          { id: 'Q3', text: 'Do you like ramen?' }
        ]
      }
    end

    let(:schema) do
      D::TestTableSchema.new(context: context)
    end

    describe 'Table#header' do
      subject { table.header(context: headers) }

      let(:headers) do
        {
          id: 'ID',
          name: 'Name',
          pets: ['Pet 1', 'Pet 2', 'Pet 3'],
          questions: %w[Q1 Q2 Q3]
        }
      end

      it {
        is_expected.to eq [
          'ID',
          'Name',
          'Pet 1',
          'Pet 2',
          'Pet 3',
          'Q1',
          'Q2',
          'Q3'
        ]
      }
    end

    describe 'Table#row' do
      subject { table.row(context: item) }

      let(:item) do
        {
          id: 1,
          name: 'Taro',
          pets: %w[cat dog],
          answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' }
        }
      end

      it {
        is_expected.to eq [
          '1',
          'Taro',
          'cat',
          'dog',
          'cat',
          'yes',
          'no',
          'yes'
        ]
      }
    end
  end

  context 'when `row_builder` is defined' do
    require 'ostruct'

    module E
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

        row_builder :to_ostruct,
                    ->(values, *) { OpenStruct.new(values) },
                    enabled_row_types: [:hash]
      end
    end

    let(:context) do
      {
        questions: [
          { id: 'Q1', text: 'Do you like sushi?' },
          { id: 'Q2', text: 'Do you like yakiniku?' },
          { id: 'Q3', text: 'Do you like ramen?' }
        ]
      }
    end

    let(:schema) do
      E::TestTableSchema.new(
        context: context,
        result_type: :hash # deprecated
      )
    end

    describe 'Table#header' do
      subject { table.header }

      it 'returns header columns' do
        expect(subject.id).to eq 'ID'
        expect(subject.name).to eq 'Name'
        expect(subject.pet1).to eq 'Pet 1'
        expect(subject.pet2).to eq 'Pet 2'
        expect(subject.pet3).to eq 'Pet 3'
        expect(subject.q1).to eq 'Q1'
        expect(subject.q2).to eq 'Q2'
        expect(subject.q3).to eq 'Q3'
      end
    end

    describe 'Table#row' do
      subject { table.row(context: item) }

      let(:item) do
        {
          id: 1,
          name: 'Taro',
          pets: %w[cat dog],
          answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' }
        }
      end

      it 'returns row columns' do
        expect(subject.id).to eq 1
        expect(subject.name).to eq 'Taro'
        expect(subject.pet1).to eq 'cat'
        expect(subject.pet2).to eq 'dog'
        expect(subject.pet3).to eq nil
        expect(subject.q1).to eq 'yes'
        expect(subject.q2).to eq 'no'
        expect(subject.q3).to eq 'yes'
      end
    end
  end

  # deprecated
  context 'result_type: :hash is specified' do
    module F
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

    let(:context) do
      {
        questions: [
          { id: 'Q1', text: 'Do you like sushi?' },
          { id: 'Q2', text: 'Do you like yakiniku?' },
          { id: 'Q3', text: 'Do you like ramen?' }
        ]
      }
    end

    let(:schema) do
      F::TestTableSchema.new(
        context: context,
        result_type: :hash # deprecated
      )
    end

    describe 'Table#header' do
      subject { table.header }

      it {
        is_expected.to eq(
          id: 'ID',
          name: 'Name',
          pet1: 'Pet 1',
          pet2: 'Pet 2',
          pet3: 'Pet 3',
          q1: 'Q1',
          q2: 'Q2',
          q3: 'Q3'
        )
      }
    end

    describe 'Table#row' do
      subject { table.row(context: item) }

      let(:item) do
        {
          id: 1,
          name: 'Taro',
          pets: %w[cat dog],
          answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' }
        }
      end

      it {
        is_expected.to eq(
          id: 1,
          name: 'Taro',
          pet1: 'cat',
          pet2: 'dog',
          pet3: nil,
          q1: 'yes',
          q2: 'no',
          q3: 'yes'
        )
      }
    end
  end

  # deprecated
  context 'when option is defined' do
    module G
      class TestTableSchema
        include TableStructure::Schema

        column  name: 'ID',
                key: :id,
                value: ->(row, *) { row[:id] }

        column  name: 'Name',
                key: :name,
                value: ->(row, *) { row[:name] }

        option :result_type, :hash # deprecated
      end
    end

    let(:schema) { G::TestTableSchema.new }

    describe 'Table#header' do
      subject { table.header }

      it {
        is_expected.to eq(
          id: 'ID',
          name: 'Name'
        )
      }
    end

    describe 'Table#row' do
      subject { table.row(context: item) }

      let(:item) do
        { id: 1, name: 'Taro' }
      end

      it {
        is_expected.to eq(
          id: 1,
          name: 'Taro'
        )
      }
    end

    context 'when overwritten by argument' do
      let(:schema) { G::TestTableSchema.new(result_type: :array) } # deprecated

      describe 'Table#header' do
        subject { table.header }

        it {
          is_expected.to eq %w[
            ID
            Name
          ]
        }
      end

      describe 'Table#row' do
        subject { table.row(context: item) }

        let(:item) do
          { id: 1, name: 'Taro' }
        end

        it {
          is_expected.to eq [
            1,
            'Taro'
          ]
        }
      end
    end
  end

  context 'when column is defined with :omitted' do
    module H
      class TestTableSchema
        include TableStructure::Schema

        column  name: 'ID',
                value: ->(row, *) { row[:id] }

        column  name: 'Name',
                value: ->(row, *) { row[:name] }

        column  name: 'Secret',
                value: '**********',
                omitted: ->(table) { !table[:admin] }
      end
    end

    let(:schema) { H::TestTableSchema.new(context: context) }

    context 'as true' do
      let(:context) { { admin: false } }

      describe 'Table#header' do
        subject { table.header }

        it {
          is_expected.to eq %w[
            ID
            Name
          ]
        }
      end

      describe 'Table#row' do
        subject { table.row(context: item) }

        let(:item) do
          { id: 1, name: 'Taro' }
        end

        it {
          is_expected.to eq [
            1,
            'Taro'
          ]
        }
      end
    end

    context 'as false' do
      let(:context) { { admin: true } }

      describe 'Table#header' do
        subject { table.header }

        it {
          is_expected.to eq %w[
            ID
            Name
            Secret
          ]
        }
      end

      describe 'Table#row' do
        subject { table.row(context: item) }

        let(:item) do
          { id: 1, name: 'Taro' }
        end

        it {
          is_expected.to eq [
            1,
            'Taro',
            '**********'
          ]
        }
      end
    end
  end

  context 'when schema is nested' do
    module I
      class TestTableSchema
        include TableStructure::Schema

        column  name: 'ID',
                key: :id,
                value: ->(row, _table) { row[:id] }

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

        column_converter :to_s, ->(val, *) { val.to_s }
      end
    end

    let(:context) do
      {
        questions: [
          { id: 'Q1', text: 'Do you like sushi?' },
          { id: 'Q2', text: 'Do you like yakiniku?' },
          { id: 'Q3', text: 'Do you like ramen?' }
        ]
      }
    end

    let(:item) do
      {
        id: 1,
        name: 'Taro',
        pets: %w[cat dog],
        answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' }
      }
    end

    shared_examples 'to return row values as array' do
      describe 'Table#header' do
        subject { table.header }

        it {
          is_expected.to eq [
            'ID',
            'Name',
            'Pet 1',
            'Pet 2',
            'Pet 3',
            'Q1',
            'Q2',
            'Q3',
            'Nested ID',
            'Nested Name',
            'Nested Pet 1',
            'Nested Pet 2',
            'Nested Pet 3',
            'Nested Q1',
            'Nested Q2',
            'Nested Q3'
          ]
        }
      end

      describe 'Table#row' do
        subject { table.row(context: item) }

        it {
          is_expected.to eq [
            '1',
            'Taro',
            'cat',
            'dog',
            '',
            'yes',
            'no',
            'yes',
            'Nested 1',
            'Nested Taro',
            'Nested cat',
            'Nested dog',
            'Nested ',
            'Nested yes',
            'Nested no',
            'Nested yes'
          ]
        }
      end
    end

    shared_examples 'to return row values as hash' do
      describe 'Table#header' do
        subject { table.header }

        it {
          is_expected.to eq(
            id: 'ID',
            name: 'Name',
            pet1: 'Pet 1',
            pet2: 'Pet 2',
            pet3: 'Pet 3',
            q1: 'Q1',
            q2: 'Q2',
            q3: 'Q3',
            nested_id: 'Nested ID',
            nested_name: 'Nested Name',
            nested_pet1: 'Nested Pet 1',
            nested_pet2: 'Nested Pet 2',
            nested_pet3: 'Nested Pet 3',
            nested_q1: 'Nested Q1',
            nested_q2: 'Nested Q2',
            nested_q3: 'Nested Q3'
          )
        }
      end

      describe 'Table#row' do
        subject { table.row(context: item) }

        it {
          is_expected.to eq(
            id: '1',
            name: 'Taro',
            pet1: 'cat',
            pet2: 'dog',
            pet3: '',
            q1: 'yes',
            q2: 'no',
            q3: 'yes',
            nested_id: 'Nested 1',
            nested_name: 'Nested Taro',
            nested_pet1: 'Nested cat',
            nested_pet2: 'Nested dog',
            nested_pet3: 'Nested ',
            nested_q1: 'Nested yes',
            nested_q2: 'Nested no',
            nested_q3: 'Nested yes'
          )
        }
      end
    end

    context 'using instance' do
      let(:schema) do
        I::TestTableSchema.new(
          context: context,
          **[{ result_type: result_type }, { row_type: result_type }].sample # deprecated
        ) do
          columns lambda { |table|
            I::TestTableSchema.new(
              context: table,
              name_prefix: 'Nested ',
              key_prefix: 'nested_'
            ) do
              column_converter :row_prefix, ->(val, *) { "Nested #{val}" }, header: false
            end
          }
        end
      end

      context 'result_type: :array' do
        let(:result_type) { :array }

        it_behaves_like 'to return row values as array'
      end

      context 'result_type: :hash' do
        let(:result_type) { :hash }

        it_behaves_like 'to return row values as hash'
      end
    end

    context 'using class' do
      module J
        class NestedTestTableSchema
          include TableStructure::Schema

          columns lambda { |table|
            I::TestTableSchema.new(
              context: table,
              key_prefix: 'nested_'
            )
          }

          column_converter :row_prefix, ->(val, *) { "Nested #{val}" }
        end
      end

      let(:schema) do
        I::TestTableSchema.new(
          context: context,
          **[{ result_type: result_type }, { row_type: result_type }].sample # deprecated
        ) do
          columns J::NestedTestTableSchema
        end
      end

      context 'result_type: :array' do
        let(:result_type) { :array }

        it_behaves_like 'to return row values as array'
      end

      context 'result_type: :hash' do
        let(:result_type) { :hash }

        it_behaves_like 'to return row values as hash'
      end
    end
  end

  context 'when schemas are concatenated' do
    module K
      class UserTableSchema
        include TableStructure::Schema

        column  name: 'ID',
                value: ->(row, *) { row[:id] }

        column  name: 'Name',
                value: ->(row, *) { row[:name] }

        column_converter :to_s, ->(val, *) { "user: #{val}" }
      end

      class PetTableSchema
        include TableStructure::Schema

        columns name: ['Pet 1', 'Pet 2', 'Pet 3'],
                value: ->(row, *) { row[:pets] }

        column_converter :to_s, ->(val, *) { "pet: #{val}" }
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

        column_converter :to_s, ->(val, *) { "question: #{val}" }
      end
    end

    let(:context) do
      {
        questions: [
          { id: 'Q1', text: 'Do you like sushi?' },
          { id: 'Q2', text: 'Do you like yakiniku?' },
          { id: 'Q3', text: 'Do you like ramen?' }
        ]
      }
    end

    let(:schema) do
      [
        K::UserTableSchema,
        K::PetTableSchema,
        K::QuestionTableSchema
      ]
        .reduce(&:+)
        .new(context: context)
    end

    describe 'Table#header' do
      subject { table.header }

      it {
        is_expected.to eq [
          'user: ID',
          'user: Name',
          'pet: Pet 1',
          'pet: Pet 2',
          'pet: Pet 3',
          'question: Q1',
          'question: Q2',
          'question: Q3'
        ]
      }
    end

    describe 'Table#row' do
      subject { table.row(context: item) }

      let(:item) do
        {
          id: 1,
          name: 'Taro',
          pets: %w[cat dog],
          answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' }
        }
      end

      it {
        is_expected.to eq [
          'user: 1',
          'user: Taro',
          'pet: cat',
          'pet: dog',
          'pet: ',
          'question: yes',
          'question: no',
          'question: yes'
        ]
      }
    end
  end

  context 'when schemas are merged' do
    module L
      class UserTableSchema
        include TableStructure::Schema

        column  name: 'ID',
                value: ->(row, *) { row[:id] }

        column  name: 'Name',
                value: ->(row, *) { row[:name] }

        column_converter :to_s, ->(*) { raise 'this column_converter will be overwritten.' }
      end

      class PetTableSchema
        include TableStructure::Schema

        columns name: ['Pet 1', 'Pet 2', 'Pet 3'],
                value: ->(row, *) { row[:pets] }

        column_converter :to_s, ->(*) { raise 'this column_converter will be overwritten.' }
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

        column_converter :to_s, ->(*) { raise 'this column_converter will be overwritten.' }
      end
    end

    let(:context) do
      {
        questions: [
          { id: 'Q1', text: 'Do you like sushi?' },
          { id: 'Q2', text: 'Do you like yakiniku?' },
          { id: 'Q3', text: 'Do you like ramen?' }
        ]
      }
    end

    let(:schema) do
      L::UserTableSchema
        .merge(
          L::PetTableSchema,
          L::QuestionTableSchema,
          ::TableStructure::Schema.create_class do
            column_converter :to_s, ->(val, *) { val.to_s }
          end
        )
        .new(context: context)
    end

    describe 'Table#header' do
      subject { table.header }

      it {
        is_expected.to eq [
          'ID',
          'Name',
          'Pet 1',
          'Pet 2',
          'Pet 3',
          'Q1',
          'Q2',
          'Q3'
        ]
      }
    end

    describe 'Table#row' do
      subject { table.row(context: item) }

      let(:item) do
        {
          id: 1,
          name: 'Taro',
          pets: %w[cat dog],
          answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' }
        }
      end

      it {
        is_expected.to eq [
          '1',
          'Taro',
          'cat',
          'dog',
          '',
          'yes',
          'no',
          'yes'
        ]
      }
    end
  end

  context 'when definitions are appended' do
    module M
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
    end

    let(:context) do
      {
        questions: [
          { id: 'Q1', text: 'Do you like sushi?' },
          { id: 'Q2', text: 'Do you like yakiniku?' },
          { id: 'Q3', text: 'Do you like ramen?' }
        ]
      }
    end

    let(:schema) do
      M::UserTableSchema.new(context: context) do
        columns M::PetTableSchema
        columns M::QuestionTableSchema
        column_converter :to_s, ->(val, *) { val.to_s }
      end
    end

    describe 'Table#header' do
      subject { table.header }

      it {
        is_expected.to eq [
          'ID',
          'Name',
          'Pet 1',
          'Pet 2',
          'Pet 3',
          'Q1',
          'Q2',
          'Q3'
        ]
      }
    end

    describe 'Table#row' do
      subject { table.row(context: item) }

      let(:item) do
        {
          id: 1,
          name: 'Taro',
          pets: %w[cat dog],
          answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' }
        }
      end

      it {
        is_expected.to eq [
          '1',
          'Taro',
          'cat',
          'dog',
          '',
          'yes',
          'no',
          'yes'
        ]
      }
    end
  end
end
