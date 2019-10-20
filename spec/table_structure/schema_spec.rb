# frozen_string_literal: true

RSpec.describe TableStructure::Schema do
  let(:table) { schema.create_table }

  context 'define column' do
    module described_class::Spec
      class TestTableSchema1
        include TableStructure::Schema

        column  name: 'ID',
                value: ->(row, *) { row[:id] }

        column  name: 'Name',
                value: ->(row, *) { row[:name] }
      end
    end

    let(:schema) { described_class::Spec::TestTableSchema1.new }

    describe 'Table#header' do
      subject { table.header }

      it 'returns header columns' do
        expect(subject.shift).to eq 'ID'
        expect(subject.shift).to eq 'Name'
        expect(subject.shift).to be_nil
      end
    end

    describe 'Table#row' do
      subject { table.row(context: item) }

      let(:item) do
        { id: 1, name: 'Taro' }
      end

      it 'returns row columns' do
        expect(subject.shift).to eq 1
        expect(subject.shift).to eq 'Taro'
        expect(subject.shift).to be_nil
      end
    end

    describe '#header_column_converters' do
      subject { table.header_column_converters.keys }
      it { is_expected.to eq [] }
    end

    describe '#row_column_converters' do
      subject { table.row_column_converters.keys }
      it { is_expected.to eq [] }
    end

    describe '#result_builders' do
      subject { table.result_builders.keys }
      it { is_expected.to eq [] }
    end
  end

  context 'define columns' do
    module described_class::Spec
      class TestTableSchema2
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

    let(:schema) do
      described_class::Spec::TestTableSchema2.new(
        context: {
          questions: [
            { id: 'Q1', text: 'Do you like sushi?' },
            { id: 'Q2', text: 'Do you like yakiniku?' },
            { id: 'Q3', text: 'Do you like ramen?' }
          ]
        }
      )
    end

    describe 'Table#header' do
      subject { table.header }

      it 'returns header columns' do
        expect(subject.shift).to eq 'ID'
        expect(subject.shift).to eq 'Name'
        expect(subject.shift).to eq 'Pet 1'
        expect(subject.shift).to eq 'Pet 2'
        expect(subject.shift).to eq 'Pet 3'
        expect(subject.shift).to eq 'Q1'
        expect(subject.shift).to eq 'Q2'
        expect(subject.shift).to eq 'Q3'
        expect(subject.shift).to be_nil
      end
    end

    describe 'Table#row' do
      subject { table.row(context: item) }

      let(:item) do
        { id: 1, name: 'Taro', pets: %w[cat dog], answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' } }
      end

      it 'returns row columns' do
        expect(subject.shift).to eq 1
        expect(subject.shift).to eq 'Taro'
        expect(subject.shift).to eq 'cat'
        expect(subject.shift).to eq 'dog'
        expect(subject.shift).to eq nil
        expect(subject.shift).to eq 'yes'
        expect(subject.shift).to eq 'no'
        expect(subject.shift).to eq 'yes'
        expect(subject.shift).to be_nil
      end
    end

    describe '#header_column_converters' do
      subject { table.header_column_converters.keys }
      it { is_expected.to eq [] }
    end

    describe '#row_column_converters' do
      subject { table.row_column_converters.keys }
      it { is_expected.to eq [] }
    end

    describe '#result_builders' do
      subject { table.result_builders.keys }
      it { is_expected.to eq [] }
    end
  end

  context 'define column_converter' do
    module described_class::Spec
      class TestTableSchema3
        include TableStructure::Schema

        column  name: 'ID',
                value: ->(row, *) { row[:id] }

        column  name: 'Name',
                value: ->(row, *) { row[:name] }

        columns name: 'Pet',
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
        column_converter :empty_to_hyphen, ->(val, *) { val.empty? ? '-' : val }
      end
    end

    let(:schema) do
      described_class::Spec::TestTableSchema3.new(
        context: {
          questions: [
            { id: 'Q1', text: 'Do you like sushi?' },
            { id: 'Q2', text: 'Do you like yakiniku?' },
            { id: 'Q3', text: 'Do you like ramen?' }
          ]
        }
      )
    end

    context 'when header: true'

    describe 'Table#header' do
      subject { table.header }

      it 'returns header columns' do
        expect(subject.shift).to eq 'ID'
        expect(subject.shift).to eq 'Name'
        expect(subject.shift).to eq 'Pet'
        expect(subject.shift).to eq '-'
        expect(subject.shift).to eq '-'
        expect(subject.shift).to eq 'Q1'
        expect(subject.shift).to eq 'Q2'
        expect(subject.shift).to eq 'Q3'
        expect(subject.shift).to be_nil
      end
    end

    describe 'Table#row' do
      subject { table.row(context: item) }

      let(:item) do
        { id: 1, name: 'Taro', pets: %w[cat dog], answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' } }
      end

      it 'returns row columns' do
        expect(subject.shift).to eq '1'
        expect(subject.shift).to eq 'Taro'
        expect(subject.shift).to eq 'cat'
        expect(subject.shift).to eq 'dog'
        expect(subject.shift).to eq '-'
        expect(subject.shift).to eq 'yes'
        expect(subject.shift).to eq 'no'
        expect(subject.shift).to eq 'yes'
        expect(subject.shift).to be_nil
      end
    end

    describe '#header_column_converters' do
      subject { table.header_column_converters.keys }
      it { is_expected.to eq %i[to_s empty_to_hyphen] }
    end

    describe '#row_column_converters' do
      subject { table.row_column_converters.keys }
      it { is_expected.to eq %i[to_s empty_to_hyphen] }
    end

    describe '#result_builders' do
      subject { table.result_builders.keys }
      it { is_expected.to eq [] }
    end
  end

  context 'define context_builder' do
    module described_class::Spec
      class TestTableSchema4
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

    let(:schema) do
      described_class::Spec::TestTableSchema4.new(
        context: {
          questions: [
            { id: 'Q1', text: 'Do you like sushi?' },
            { id: 'Q2', text: 'Do you like yakiniku?' },
            { id: 'Q3', text: 'Do you like ramen?' }
          ]
        }
      )
    end

    describe 'Table#header' do
      subject { table.header(context: header) }

      let(:header) do
        {
          id: 'ID',
          name: 'Name',
          pets: ['Pet 1', 'Pet 2', 'Pet 3'],
          questions: %w[Q1 Q2 Q3]
        }
      end

      it 'returns header columns' do
        expect(subject.shift).to eq 'ID'
        expect(subject.shift).to eq 'Name'
        expect(subject.shift).to eq 'Pet 1'
        expect(subject.shift).to eq 'Pet 2'
        expect(subject.shift).to eq 'Pet 3'
        expect(subject.shift).to eq 'Q1'
        expect(subject.shift).to eq 'Q2'
        expect(subject.shift).to eq 'Q3'
        expect(subject.shift).to be_nil
      end
    end

    describe 'Table#row' do
      subject { table.row(context: item) }

      let(:item) do
        { id: 1, name: 'Taro', pets: %w[cat dog], answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' } }
      end

      it 'returns row columns' do
        expect(subject.shift).to eq '1'
        expect(subject.shift).to eq 'Taro'
        expect(subject.shift).to eq 'cat'
        expect(subject.shift).to eq 'dog'
        expect(subject.shift).to eq 'cat'
        expect(subject.shift).to eq 'yes'
        expect(subject.shift).to eq 'no'
        expect(subject.shift).to eq 'yes'
        expect(subject.shift).to be_nil
      end
    end

    describe '#header_column_converters' do
      subject { table.header_column_converters.keys }
      it { is_expected.to eq %i[nil_to_hyphen to_s] }
    end

    describe '#row_column_converters' do
      subject { table.row_column_converters.keys }
      it { is_expected.to eq %i[nil_to_hyphen to_s] }
    end

    describe '#result_builders' do
      subject { table.result_builders.keys }
      it { is_expected.to eq [] }
    end
  end

  context 'define result_builder' do
    require 'ostruct'

    module described_class::Spec
      class TestTableSchema5
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

        result_builder  :to_ostruct,
                        ->(values, *) { OpenStruct.new(values) },
                        enabled_result_types: [:hash]
      end
    end

    let(:schema) do
      described_class::Spec::TestTableSchema5.new(
        context: {
          questions: [
            { id: 'Q1', text: 'Do you like sushi?' },
            { id: 'Q2', text: 'Do you like yakiniku?' },
            { id: 'Q3', text: 'Do you like ramen?' }
          ]
        },
        result_type: :hash
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
        { id: 1, name: 'Taro', pets: %w[cat dog], answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' } }
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

    describe '#header_column_converters' do
      subject { table.header_column_converters.keys }
      it { is_expected.to eq [] }
    end

    describe '#row_column_converters' do
      subject { table.row_column_converters.keys }
      it { is_expected.to eq [] }
    end

    describe '#result_builders' do
      subject { table.result_builders.keys }
      it { is_expected.to eq %i[to_hash to_ostruct] }
    end
  end

  context 'specify result_type: :hash' do
    module described_class::Spec
      class TestTableSchema6
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

    let(:schema) do
      described_class::Spec::TestTableSchema6.new(
        context: {
          questions: [
            { id: 'Q1', text: 'Do you like sushi?' },
            { id: 'Q2', text: 'Do you like yakiniku?' },
            { id: 'Q3', text: 'Do you like ramen?' }
          ]
        },
        result_type: :hash
      )
    end

    describe 'Table#header' do
      subject { table.header }

      it 'returns header columns' do
        expect(subject[:id]).to eq 'ID'
        expect(subject[:name]).to eq 'Name'
        expect(subject[:pet1]).to eq 'Pet 1'
        expect(subject[:pet2]).to eq 'Pet 2'
        expect(subject[:pet3]).to eq 'Pet 3'
        expect(subject[:q1]).to eq 'Q1'
        expect(subject[:q2]).to eq 'Q2'
        expect(subject[:q3]).to eq 'Q3'
      end
    end

    describe 'Table#row' do
      subject { table.row(context: item) }

      let(:item) do
        { id: 1, name: 'Taro', pets: %w[cat dog], answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' } }
      end

      it 'returns row columns' do
        expect(subject[:id]).to eq 1
        expect(subject[:name]).to eq 'Taro'
        expect(subject[:pet1]).to eq 'cat'
        expect(subject[:pet2]).to eq 'dog'
        expect(subject[:pet3]).to eq nil
        expect(subject[:q1]).to eq 'yes'
        expect(subject[:q2]).to eq 'no'
        expect(subject[:q3]).to eq 'yes'
      end
    end

    describe '#header_column_converters' do
      subject { table.header_column_converters.keys }
      it { is_expected.to eq [] }
    end

    describe '#row_column_converters' do
      subject { table.row_column_converters.keys }
      it { is_expected.to eq [] }
    end

    describe '#result_builders' do
      subject { table.result_builders.keys }
      it { is_expected.to eq [:to_hash] }
    end
  end

  context 'define option' do
    module described_class::Spec
      class TestTableSchema7
        include TableStructure::Schema

        column  name: 'ID',
                key: :id,
                value: ->(row, *) { row[:id] }

        column  name: 'Name',
                key: :name,
                value: ->(row, *) { row[:name] }

        option :result_type, :hash
      end
    end

    let(:schema) { described_class::Spec::TestTableSchema7.new }

    describe 'Table#header' do
      subject { table.header }

      it 'returns header columns' do
        expect(subject[:id]).to eq 'ID'
        expect(subject[:name]).to eq 'Name'
      end
    end

    describe 'Table#row' do
      subject { table.row(context: item) }

      let(:item) do
        { id: 1, name: 'Taro' }
      end

      it 'returns row columns' do
        expect(subject[:id]).to eq 1
        expect(subject[:name]).to eq 'Taro'
      end
    end

    describe '#header_column_converters' do
      subject { table.header_column_converters.keys }
      it { is_expected.to eq [] }
    end

    describe '#row_column_converters' do
      subject { table.row_column_converters.keys }
      it { is_expected.to eq [] }
    end

    describe '#result_builders' do
      subject { table.result_builders.keys }
      it { is_expected.to eq [:to_hash] }
    end

    context 'overwrite by argument' do
      let(:schema) { described_class::Spec::TestTableSchema7.new(result_type: :array) }

      describe 'Table#header' do
        subject { table.header }

        it 'returns header columns' do
          expect(subject.shift).to eq 'ID'
          expect(subject.shift).to eq 'Name'
          expect(subject.shift).to be_nil
        end
      end

      describe 'Table#row' do
        subject { table.row(context: item) }

        let(:item) do
          { id: 1, name: 'Taro' }
        end

        it 'returns row columns' do
          expect(subject.shift).to eq 1
          expect(subject.shift).to eq 'Taro'
          expect(subject.shift).to be_nil
        end
      end

      describe '#header_column_converters' do
        subject { table.header_column_converters.keys }
        it { is_expected.to eq [] }
      end

      describe '#row_column_converters' do
        subject { table.row_column_converters.keys }
        it { is_expected.to eq [] }
      end

      describe '#result_builders' do
        subject { table.result_builders.keys }
        it { is_expected.to eq [] }
      end
    end
  end

  context 'define column with :omitted' do
    module described_class::Spec
      class TestTableSchema8
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

    let(:schema) { described_class::Spec::TestTableSchema8.new(context: context) }

    context 'as true' do
      let(:context) { { admin: false } }

      describe 'Table#header' do
        subject { table.header }

        it 'returns header columns' do
          expect(subject.shift).to eq 'ID'
          expect(subject.shift).to eq 'Name'
          expect(subject.shift).to be_nil
        end
      end

      describe 'Table#row' do
        subject { table.row(context: item) }

        let(:item) do
          { id: 1, name: 'Taro' }
        end

        it 'returns row columns' do
          expect(subject.shift).to eq 1
          expect(subject.shift).to eq 'Taro'
          expect(subject.shift).to be_nil
        end
      end

      describe '#header_column_converters' do
        subject { table.header_column_converters.keys }
        it { is_expected.to eq [] }
      end

      describe '#row_column_converters' do
        subject { table.row_column_converters.keys }
        it { is_expected.to eq [] }
      end

      describe '#result_builders' do
        subject { table.result_builders.keys }
        it { is_expected.to eq [] }
      end
    end

    context 'as false' do
      let(:context) { { admin: true } }

      describe 'Table#header' do
        subject { table.header }

        it 'returns header columns' do
          expect(subject.shift).to eq 'ID'
          expect(subject.shift).to eq 'Name'
          expect(subject.shift).to eq 'Secret'
          expect(subject.shift).to be_nil
        end
      end

      describe 'Table#row' do
        subject { table.row(context: item) }

        let(:item) do
          { id: 1, name: 'Taro' }
        end

        it 'returns row columns' do
          expect(subject.shift).to eq 1
          expect(subject.shift).to eq 'Taro'
          expect(subject.shift).to eq '**********'
          expect(subject.shift).to be_nil
        end
      end

      describe '#header_column_converters' do
        subject { table.header_column_converters.keys }
        it { is_expected.to eq [] }
      end

      describe '#row_column_converters' do
        subject { table.row_column_converters.keys }
        it { is_expected.to eq [] }
      end

      describe '#result_builders' do
        subject { table.result_builders.keys }
        it { is_expected.to eq [] }
      end
    end
  end

  context 'nest schema' do
    context 'as instance' do
      module described_class::Spec
        class NestedTestTableSchema9
          include TableStructure::Schema

          column  name: 'ID',
                  key: :id,
                  value: ->(row, _table) { row[:id] }

          column  name: 'Name',
                  key: :name,
                  value: ->(row, *) { row[:name] }

          columns name: 'Pets',
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

          column_converter :nil_to_hyphen, ->(val, *) { val.nil? ? '-' : val }
        end

        class TestTableSchema9
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

          columns lambda { |table|
            NestedTestTableSchema9.new(context: table, name_prefix: 'Nested ', key_prefix: 'nested_')
          }

          column_converter :to_s, ->(val, *) { val.to_s }
        end
      end

      let(:schema) do
        described_class::Spec::TestTableSchema9.new(
          context: {
            questions: [
              { id: 'Q1', text: 'Do you like sushi?' },
              { id: 'Q2', text: 'Do you like yakiniku?' },
              { id: 'Q3', text: 'Do you like ramen?' }
            ]
          },
          result_type: result_type
        )
      end

      let(:item) do
        { id: 1, name: 'Taro', pets: %w[cat dog], answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' } }
      end

      context 'result_type: :array' do
        let(:result_type) { :array }

        describe 'Table#header' do
          subject { table.header }

          it 'returns header columns' do
            expect(subject.shift).to eq 'ID'
            expect(subject.shift).to eq 'Name'
            expect(subject.shift).to eq 'Pet 1'
            expect(subject.shift).to eq 'Pet 2'
            expect(subject.shift).to eq 'Pet 3'
            expect(subject.shift).to eq 'Q1'
            expect(subject.shift).to eq 'Q2'
            expect(subject.shift).to eq 'Q3'
            expect(subject.shift).to eq 'Nested ID'
            expect(subject.shift).to eq 'Nested Name'
            expect(subject.shift).to eq 'Nested Pets'
            expect(subject.shift).to eq '-'
            expect(subject.shift).to eq '-'
            expect(subject.shift).to eq 'Nested Q1'
            expect(subject.shift).to eq 'Nested Q2'
            expect(subject.shift).to eq 'Nested Q3'
            expect(subject.shift).to be_nil
          end
        end

        describe 'Table#row' do
          subject { table.row(context: item) }

          it 'returns row columns' do
            expect(subject.shift).to eq '1'
            expect(subject.shift).to eq 'Taro'
            expect(subject.shift).to eq 'cat'
            expect(subject.shift).to eq 'dog'
            expect(subject.shift).to eq ''
            expect(subject.shift).to eq 'yes'
            expect(subject.shift).to eq 'no'
            expect(subject.shift).to eq 'yes'
            expect(subject.shift).to eq '1'
            expect(subject.shift).to eq 'Taro'
            expect(subject.shift).to eq 'cat'
            expect(subject.shift).to eq 'dog'
            expect(subject.shift).to eq '-'
            expect(subject.shift).to eq 'yes'
            expect(subject.shift).to eq 'no'
            expect(subject.shift).to eq 'yes'
            expect(subject.shift).to be_nil
          end
        end

        describe '#header_column_converters' do
          subject { table.header_column_converters.keys }
          it { is_expected.to eq %i[to_s] }
        end

        describe '#row_column_converters' do
          subject { table.row_column_converters.keys }
          it { is_expected.to eq %i[to_s] }
        end

        describe '#result_builders' do
          subject { table.result_builders.keys }
          it { is_expected.to eq [] }
        end
      end

      context 'result_type: :hash' do
        let(:result_type) { :hash }

        describe 'Table#header' do
          subject { table.header }

          it 'returns header columns' do
            expect(subject[:id]).to eq 'ID'
            expect(subject[:name]).to eq 'Name'
            expect(subject[:pet1]).to eq 'Pet 1'
            expect(subject[:pet2]).to eq 'Pet 2'
            expect(subject[:pet3]).to eq 'Pet 3'
            expect(subject[:q1]).to eq 'Q1'
            expect(subject[:q2]).to eq 'Q2'
            expect(subject[:q3]).to eq 'Q3'
            expect(subject[:nested_id]).to eq 'Nested ID'
            expect(subject[:nested_name]).to eq 'Nested Name'
            expect(subject[:nested_pet1]).to eq 'Nested Pets'
            expect(subject[:nested_pet2]).to eq '-'
            expect(subject[:nested_pet3]).to eq '-'
            expect(subject[:nested_q1]).to eq 'Nested Q1'
            expect(subject[:nested_q2]).to eq 'Nested Q2'
            expect(subject[:nested_q3]).to eq 'Nested Q3'
          end
        end

        describe 'Table#row' do
          subject { table.row(context: item) }

          it 'returns row columns' do
            expect(subject[:id]).to eq '1'
            expect(subject[:name]).to eq 'Taro'
            expect(subject[:pet1]).to eq 'cat'
            expect(subject[:pet2]).to eq 'dog'
            expect(subject[:pet3]).to eq ''
            expect(subject[:q1]).to eq 'yes'
            expect(subject[:q2]).to eq 'no'
            expect(subject[:q3]).to eq 'yes'
            expect(subject[:nested_id]).to eq '1'
            expect(subject[:nested_name]).to eq 'Taro'
            expect(subject[:nested_pet1]).to eq 'cat'
            expect(subject[:nested_pet2]).to eq 'dog'
            expect(subject[:nested_pet3]).to eq '-'
            expect(subject[:nested_q1]).to eq 'yes'
            expect(subject[:nested_q2]).to eq 'no'
            expect(subject[:nested_q3]).to eq 'yes'
          end
        end

        describe '#header_column_converters' do
          subject { table.header_column_converters.keys }
          it { is_expected.to eq %i[to_s] }
        end

        describe '#row_column_converters' do
          subject { table.row_column_converters.keys }
          it { is_expected.to eq %i[to_s] }
        end

        describe '#result_builders' do
          subject { table.result_builders.keys }
          it { is_expected.to eq [:to_hash] }
        end
      end
    end

    context 'as class' do
      module described_class::Spec
        class NestedTestTableSchemaA
          include TableStructure::Schema

          column  name: 'ID',
                  key: :nested_id,
                  value: ->(row, _table) { row[:id] }

          column  name: 'Name',
                  key: :nested_name,
                  value: ->(row, *) { row[:name] }

          columns name: ['Pet 1', 'Pet 2', 'Pet 3'],
                  key: %i[nested_pet1 nested_pet2 nested_pet3],
                  value: ->(row, *) { row[:pets] }

          columns lambda { |table|
            table[:questions].map do |question|
              {
                name: question[:id],
                key: "nested_#{question[:id]}".downcase.to_sym,
                value: ->(row, *) { row[:answers][question[:id]] }
              }
            end
          }

          column_converter :nil_to_hyphen, ->(val, *) { val.nil? ? '-' : val }
        end

        class TestTableSchemaA
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

          columns NestedTestTableSchemaA

          column_converter :to_s, ->(val, *) { val.to_s }
        end
      end

      let(:schema) do
        described_class::Spec::TestTableSchemaA.new(
          context: {
            questions: [
              { id: 'Q1', text: 'Do you like sushi?' },
              { id: 'Q2', text: 'Do you like yakiniku?' },
              { id: 'Q3', text: 'Do you like ramen?' }
            ]
          },
          result_type: result_type
        )
      end

      let(:item) do
        { id: 1, name: 'Taro', pets: %w[cat dog], answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' } }
      end

      context 'result_type: :array' do
        let(:result_type) { :array }

        describe 'Table#header' do
          subject { table.header }

          it 'returns header columns' do
            expect(subject.shift).to eq 'ID'
            expect(subject.shift).to eq 'Name'
            expect(subject.shift).to eq 'Pet 1'
            expect(subject.shift).to eq 'Pet 2'
            expect(subject.shift).to eq 'Pet 3'
            expect(subject.shift).to eq 'Q1'
            expect(subject.shift).to eq 'Q2'
            expect(subject.shift).to eq 'Q3'
            expect(subject.shift).to eq 'ID'
            expect(subject.shift).to eq 'Name'
            expect(subject.shift).to eq 'Pet 1'
            expect(subject.shift).to eq 'Pet 2'
            expect(subject.shift).to eq 'Pet 3'
            expect(subject.shift).to eq 'Q1'
            expect(subject.shift).to eq 'Q2'
            expect(subject.shift).to eq 'Q3'
            expect(subject.shift).to be_nil
          end
        end

        describe 'Table#row' do
          subject { table.row(context: item) }

          it 'returns row columns' do
            expect(subject.shift).to eq '1'
            expect(subject.shift).to eq 'Taro'
            expect(subject.shift).to eq 'cat'
            expect(subject.shift).to eq 'dog'
            expect(subject.shift).to eq ''
            expect(subject.shift).to eq 'yes'
            expect(subject.shift).to eq 'no'
            expect(subject.shift).to eq 'yes'
            expect(subject.shift).to eq '1'
            expect(subject.shift).to eq 'Taro'
            expect(subject.shift).to eq 'cat'
            expect(subject.shift).to eq 'dog'
            expect(subject.shift).to eq '-'
            expect(subject.shift).to eq 'yes'
            expect(subject.shift).to eq 'no'
            expect(subject.shift).to eq 'yes'
            expect(subject.shift).to be_nil
          end
        end

        describe '#header_column_converters' do
          subject { table.header_column_converters.keys }
          it { is_expected.to eq %i[to_s] }
        end

        describe '#row_column_converters' do
          subject { table.row_column_converters.keys }
          it { is_expected.to eq %i[to_s] }
        end

        describe '#result_builders' do
          subject { table.result_builders.keys }
          it { is_expected.to eq [] }
        end
      end

      context 'result_type: :hash' do
        let(:result_type) { :hash }

        describe 'Table#header' do
          subject { table.header }

          it 'returns header columns' do
            expect(subject[:id]).to eq 'ID'
            expect(subject[:name]).to eq 'Name'
            expect(subject[:pet1]).to eq 'Pet 1'
            expect(subject[:pet2]).to eq 'Pet 2'
            expect(subject[:pet3]).to eq 'Pet 3'
            expect(subject[:q1]).to eq 'Q1'
            expect(subject[:q2]).to eq 'Q2'
            expect(subject[:q3]).to eq 'Q3'
            expect(subject[:nested_id]).to eq 'ID'
            expect(subject[:nested_name]).to eq 'Name'
            expect(subject[:nested_pet1]).to eq 'Pet 1'
            expect(subject[:nested_pet2]).to eq 'Pet 2'
            expect(subject[:nested_pet3]).to eq 'Pet 3'
            expect(subject[:nested_q1]).to eq 'Q1'
            expect(subject[:nested_q2]).to eq 'Q2'
            expect(subject[:nested_q3]).to eq 'Q3'
          end
        end

        describe 'Table#row' do
          subject { table.row(context: item) }

          it 'returns row columns' do
            expect(subject[:id]).to eq '1'
            expect(subject[:name]).to eq 'Taro'
            expect(subject[:pet1]).to eq 'cat'
            expect(subject[:pet2]).to eq 'dog'
            expect(subject[:pet3]).to eq ''
            expect(subject[:q1]).to eq 'yes'
            expect(subject[:q2]).to eq 'no'
            expect(subject[:q3]).to eq 'yes'
            expect(subject[:nested_id]).to eq '1'
            expect(subject[:nested_name]).to eq 'Taro'
            expect(subject[:nested_pet1]).to eq 'cat'
            expect(subject[:nested_pet2]).to eq 'dog'
            expect(subject[:nested_pet3]).to eq '-'
            expect(subject[:nested_q1]).to eq 'yes'
            expect(subject[:nested_q2]).to eq 'no'
            expect(subject[:nested_q3]).to eq 'yes'
          end
        end

        describe '#header_column_converters' do
          subject { table.header_column_converters.keys }
          it { is_expected.to eq %i[to_s] }
        end

        describe '#row_column_converters' do
          subject { table.row_column_converters.keys }
          it { is_expected.to eq %i[to_s] }
        end

        describe '#result_builders' do
          subject { table.result_builders.keys }
          it { is_expected.to eq [:to_hash] }
        end
      end
    end
  end
end
