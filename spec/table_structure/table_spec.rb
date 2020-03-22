# frozen_string_literal: true

RSpec.describe TableStructure::Table do
  let(:table) { described_class.new(schema, row_type: row_type) }

  context 'when several `columns` are defined' do
    include_context 'questions'

    let(:row_type) { :array }

    schema_classes = [
      ::Mono::TestTableSchema,
      ::Mono::WithKeys::TestTableSchema,
      ::Micro::Nested::TestTableSchema,
      ::Micro::Concatenated::TestTableSchema,
      ::Micro::Merged::TestTableSchema
    ]

    schema_classes.each do |schema_class|
      let(:schema) do
        schema_class.new(context: { questions: questions })
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

      describe 'Table#body' do
        include_context 'users'

        subject { table.body(users).first }

        it {
          is_expected.to eq [
            1,
            '太郎',
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
  end

  context 'when several definitions are appended in block' do
    include_context 'questions'

    let(:row_type) { :array }

    let(:schema) do
      ::Micro::UserTableSchema.new(context: { questions: questions }) do
        columns ::Micro::PetTableSchema
        columns ::Micro::QuestionTableSchema
        if [true, false].sample # deprecated
          column_converter :to_s, ->(val, *) { val.to_s }
        else
          column_converter :to_s do |val, *|
            val.to_s
          end
        end
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

    describe 'Table#body' do
      include_context 'users'

      subject { table.body(users).first }

      it {
        is_expected.to eq [
          '1',
          '太郎',
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

  context 'when several `column_converter` are defined' do
    module ColumnConverter
      class TestTableSchema
        include ::TableStructure::Schema

        columns ::Mono::TestTableSchema

        if [true, false].sample # deprecated
          column_converter :to_s, ->(val, *) { val.to_s }
          column_converter :empty_to_hyphen, ->(val, *) { val.empty? ? '-' : val }, header: true, row: true
        else
          column_converter :to_s do |val, *|
            val.to_s
          end

          column_converter :empty_to_hyphen, header: true, row: true do |val, *|
            val.empty? ? '-' : val
          end
        end
      end
    end

    include_context 'questions'

    let(:row_type) { :array }

    let(:schema) do
      ColumnConverter::TestTableSchema.new(context: { questions: questions })
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

    describe 'Table#body' do
      include_context 'users'

      subject { table.body(users).first }

      it {
        is_expected.to eq [
          '1',
          '太郎',
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

  context 'when several `context_builder` are defined' do
    module ContextBuilder
      class TestTableSchema
        include ::TableStructure::Schema

        TableContext = Struct.new(:questions)

        HeaderContext = Struct.new(:id, :name, :pets, :questions)

        RowContext = Struct.new(:id, :name, :pets, :answers) do
          def more_pets
            pets + pets
          end
        end

        if [true, false].sample # deprecated
          context_builder :table, ->(context) { TableContext.new(*context.values) }
          context_builder :header, ->(context) { HeaderContext.new(*context.values) } # TODO: will remove or rename
          context_builder :row, ->(context) { RowContext.new(*context.values) }
        else
          context_builder :table do |context|
            TableContext.new(*context.values)
          end

          context_builder :header do |context|
            HeaderContext.new(*context.values)
          end

          context_builder :row do |context|
            RowContext.new(*context.values)
          end
        end

        column  name: ->(row, *) { row.id },
                value: ->(row, *) { row.id },
                size: 1

        column  name: ->(row, *) { row.name },
                value: ->(row, *) { row.name },
                size: 1

        columns name: ->(row, *) { row.pets },
                value: ->(row, *) { row.more_pets },
                size: 3

        columns lambda { |table|
          table.questions.map.with_index do |question, i|
            {
              name: ->(row, table) { "#{row.questions[i]}:#{table.questions[i][:text]}" },
              value: ->(row, table) { "#{table.questions[i][:id]}:#{row.answers[question[:id]]}" },
              size: 1
            }
          end
        }
      end
    end

    include_context 'questions'

    let(:row_type) { :array }

    let(:schema) do
      ContextBuilder::TestTableSchema.new(context: { questions: questions })
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
          'Q1:Do you like sushi?',
          'Q2:Do you like yakiniku?',
          'Q3:Do you like ramen?'
        ]
      }
    end

    describe 'Table#row' do
      include_context 'users'

      subject { table.body(users).first }

      it {
        is_expected.to eq [
          1,
          '太郎',
          'cat',
          'dog',
          'cat',
          'Q1:yes',
          'Q2:no',
          'Q3:yes'
        ]
      }
    end
  end

  context 'when `:row_type` is set `:hash`' do
    include_context 'questions'

    let(:row_type) { :hash }

    let(:schema) do
      ::Mono::WithKeys::TestTableSchema.new(
        context: { questions: questions }
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

    describe 'Table#body' do
      include_context 'users'

      subject { table.body(users).first }

      it {
        is_expected.to eq(
          id: 1,
          name: '太郎',
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

  context 'when `row_builder` is defined' do
    include_context 'questions'

    require 'ostruct'

    let(:row_type) { :hash }

    let(:schema) do
      ::Mono::WithKeys::TestTableSchema.new(
        context: { questions: questions }
      ) do
        row_builder :to_ostruct,
                    ->(values, *) { OpenStruct.new(values) },
                    enabled_row_types: [:hash]
      end
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

    describe 'Table#body' do
      include_context 'users'

      subject { table.body(users).first }

      it 'returns row columns' do
        expect(subject.id).to eq 1
        expect(subject.name).to eq '太郎'
        expect(subject.pet1).to eq 'cat'
        expect(subject.pet2).to eq 'dog'
        expect(subject.pet3).to eq nil
        expect(subject.q1).to eq 'yes'
        expect(subject.q2).to eq 'no'
        expect(subject.q3).to eq 'yes'
      end
    end
  end

  context 'when `:omitted` is defined' do
    module Omitted
      class TestTableSchema
        include ::TableStructure::Schema

        columns ::Micro::UserTableSchema

        column  name: 'Secret',
                value: '**********',
                omitted: ->(table) { !table[:admin] }
      end
    end

    let(:row_type) { :array }

    let(:schema) { Omitted::TestTableSchema.new(context: context) }

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

      describe 'Table#body' do
        include_context 'users'

        subject { table.body(users).first }

        it {
          is_expected.to eq [
            1,
            '太郎'
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

      describe 'Table#body' do
        include_context 'users'

        subject { table.body(users).first }

        it {
          is_expected.to eq [
            1,
            '太郎',
            '**********'
          ]
        }
      end
    end
  end

  context 'when `:nil_definitions_ignored` is specified' do
    module NilDefinitionsIgnored
      class TestTableSchema
        include ::TableStructure::Schema

        columns ::Micro::UserTableSchema

        column  nil
        column  ->(*) { nil }

        columns [nil, nil]
        columns ->(*) { [nil, nil] }

        columns []
        columns ->(*) { [] }
      end
    end

    let(:row_type) { :array }

    let(:schema) do
      NilDefinitionsIgnored::TestTableSchema.new(
        nil_definitions_ignored: nil_definitions_ignored
      )
    end

    context 'as true' do
      let(:nil_definitions_ignored) { true }

      describe 'Table#header' do
        subject { table.header }

        it {
          is_expected.to eq %w[
            ID
            Name
          ]
        }
      end

      describe 'Table#body' do
        include_context 'users'

        subject { table.body(users).first }

        it {
          is_expected.to eq [
            1,
            '太郎'
          ]
        }
      end
    end

    context 'as false' do
      let(:nil_definitions_ignored) { false }

      describe 'Table#header' do
        subject { table.header }

        it { expect { subject }.to raise_error ::TableStructure::Schema::Definition::Columns::Error }
      end

      describe 'Table#body' do
        include_context 'users'

        subject { table.body(users).first }

        it { expect { subject }.to raise_error ::TableStructure::Schema::Definition::Columns::Error }
      end
    end
  end

  context 'when schema is nested' do
    include_context 'questions'
    include_context 'users'

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
        subject { table.body(users).first }

        it {
          is_expected.to eq [
            '1',
            '太郎',
            'cat',
            'dog',
            '',
            'yes',
            'no',
            'yes',
            'Nested 1',
            'Nested 太郎',
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
        subject { table.body(users).first }

        it {
          is_expected.to eq(
            id: '1',
            name: '太郎',
            pet1: 'cat',
            pet2: 'dog',
            pet3: '',
            q1: 'yes',
            q2: 'no',
            q3: 'yes',
            nested_id: 'Nested 1',
            nested_name: 'Nested 太郎',
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
        ::Mono::WithKeys::TestTableSchema.new(
          context: { questions: questions }
        ) do
          columns lambda { |table|
            ::Mono::WithKeys::TestTableSchema.new(
              context: table,
              name_prefix: 'Nested ',
              key_prefix: 'nested_'
            ) do
              if [true, false].sample # deprecated
                column_converter :row_prefix, ->(val, *) { "Nested #{val}" }, header: false
              else
                column_converter :row_prefix, header: false do |val, *|
                  "Nested #{val}"
                end
              end
            end
          }

          if [true, false].sample # deprecated
            column_converter :to_s, ->(val, *) { val.to_s }
          else
            column_converter :to_s do |val, *|
              val.to_s
            end
          end
        end
      end

      context 'row_type: :array' do
        let(:row_type) { :array }

        it_behaves_like 'to return row values as array'
      end

      context 'row_type: :hash' do
        let(:row_type) { :hash }

        it_behaves_like 'to return row values as hash'
      end
    end

    context 'using class' do
      module Nested
        class TestTableSchema
          include ::TableStructure::Schema

          columns lambda { |table|
            ::Mono::WithKeys::TestTableSchema.new(
              context: table,
              key_prefix: 'nested_'
            )
          }

          if [true, false].sample # deprecated
            column_converter :row_prefix, ->(val, *) { "Nested #{val}" }
          else
            column_converter :row_prefix do |val, *|
              "Nested #{val}"
            end
          end
        end
      end

      let(:schema) do
        ::Mono::WithKeys::TestTableSchema.new(
          context: { questions: questions }
        ) do
          columns Nested::TestTableSchema

          if [true, false].sample # deprecated
            column_converter :to_s, ->(val, *) { val.to_s }
          else
            column_converter :to_s do |val, *|
              val.to_s
            end
          end
        end
      end

      context 'row_type: :array' do
        let(:row_type) { :array }

        it_behaves_like 'to return row values as array'
      end

      context 'row_type: :hash' do
        let(:row_type) { :hash }

        it_behaves_like 'to return row values as hash'
      end
    end
  end

  context 'when several schemas are concatenated' do
    module Concatenated
      class UserTableSchema
        include ::TableStructure::Schema

        context_builder :row do |context|
          {
            user_id: context[:id],
            user_name: context[:name]
          }
        end

        column  name: 'ID',
                key: :id,
                value: ->(row, *) { row[:user_id] }

        column  name: 'Name',
                key: :name,
                value: ->(row, *) { row[:user_name] }

        column_converter :to_s do |val, *|
          "user: #{val}"
        end
      end

      class PetTableSchema
        include ::TableStructure::Schema

        context_builder :row do |context|
          {
            user_pets: context[:pets]
          }
        end

        columns name: ['Pet 1', 'Pet 2', 'Pet 3'],
                key: %i[pet1 pet2 pet3],
                value: ->(row, *) { row[:user_pets] }

        column_converter :to_s do |val, *|
          "pet: #{val}"
        end
      end

      class QuestionTableSchema
        include ::TableStructure::Schema

        context_builder :table do |context|
          context.map { |k, v| [k.to_s, v] }.to_h
        end

        context_builder :row do |context|
          {
            user_answers: context[:answers]
          }
        end

        columns lambda { |table|
          table['questions'].map do |question|
            {
              name: question[:id],
              key: question[:id].downcase.to_sym,
              value: ->(row, *) { row[:user_answers][question[:id]] }
            }
          end
        }

        column_converter :to_s do |val, *|
          "question: #{val}"
        end
      end
    end

    include_context 'questions'

    let(:row_type) { :array }

    let(:schema) do
      [
        Concatenated::UserTableSchema,
        Concatenated::PetTableSchema,
        Concatenated::QuestionTableSchema
      ]
        .reduce(&:+)
        .new(context: { questions: questions })
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

    describe 'Table#body' do
      include_context 'users'

      subject { table.body(users).first }

      it {
        is_expected.to eq [
          'user: 1',
          'user: 太郎',
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

  context 'when several schemas are merged' do
    module Merged
      class UserTableSchema
        include ::TableStructure::Schema

        context_builder :table do
          raise 'this context_builder will be overwritten.'
        end

        context_builder :row do
          raise 'this context_builder will be overwritten.'
        end

        columns ::Micro::UserTableSchema

        column_converter :to_s do
          raise 'this column_converter will be overwritten.'
        end
      end

      class PetTableSchema
        include ::TableStructure::Schema

        context_builder :table do
          raise 'this context_builder will be overwritten.'
        end

        context_builder :row do
          raise 'this context_builder will be overwritten.'
        end

        columns ::Micro::PetTableSchema

        column_converter :to_s do
          raise 'this column_converter will be overwritten.'
        end
      end

      class QuestionTableSchema
        include ::TableStructure::Schema

        context_builder :table do
          raise 'this context_builder will be overwritten.'
        end

        context_builder :row do
          raise 'this context_builder will be overwritten.'
        end

        columns ::Micro::QuestionTableSchema

        column_converter :to_s do
          raise 'this column_converter will be overwritten.'
        end
      end
    end

    include_context 'questions'

    let(:row_type) { :array }

    let(:schema) do
      Merged::UserTableSchema
        .merge(
          Merged::PetTableSchema,
          Merged::QuestionTableSchema,
          ::TableStructure::Schema.create_class do
            context_builder :table do |context|
              context
            end

            context_builder :row do |context|
              context
            end

            column_converter :to_s do |val, *|
              val.to_s
            end
          end
        )
        .new(context: { questions: questions })
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

    describe 'Table#body' do
      include_context 'users'

      subject { table.body(users).first }

      it {
        is_expected.to eq [
          '1',
          '太郎',
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

  context 'when the same schemas are nested' do
    let(:schema) do
      ::TableStructure::Schema.create_class do
        columns ::Micro::WithKeys::UserTableSchema
        columns proc {
          ::Micro::WithKeys::UserTableSchema.new(
            name_prefix: 'Partner ',
            key_prefix: 'partner_'
          ) do
            context_builder :row do |context|
              context[:partner]
            end

            column_converter :to_s do |val, *|
              val.to_s
            end
          end
        }
      end.new
    end

    context 'row_type: :array' do
      let(:row_type) { :array }

      describe 'Table#header' do
        subject { table.header }

        it {
          is_expected.to eq [
            'ID',
            'Name',
            'Partner ID',
            'Partner Name'
          ]
        }
      end

      describe 'Table#body' do
        include_context 'users'

        subject { table.body(nested_users).first }

        it {
          is_expected.to eq [
            1,
            '太郎',
            '2',
            '花子'
          ]
        }
      end
    end

    context 'row_type: :hash' do
      let(:row_type) { :hash }

      describe 'Table#header' do
        subject { table.header }

        it {
          is_expected.to eq(
            id: 'ID',
            name: 'Name',
            partner_id: 'Partner ID',
            partner_name: 'Partner Name'
          )
        }
      end

      describe 'Table#body' do
        include_context 'users'

        subject { table.body(nested_users).first }

        it {
          is_expected.to eq(
            id: 1,
            name: '太郎',
            partner_id: '2',
            partner_name: '花子'
          )
        }
      end
    end
  end
end
