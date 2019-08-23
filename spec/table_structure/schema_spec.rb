# frozen_string_literal: true

RSpec.describe TableStructure::Schema do
  context 'define column' do
    class TestTableSchema11
      include TableStructure::Schema

      column  name: 'ID',
              value: ->(row, *) { row[:id] }

      column  name: 'Name',
              value: ->(row, *) { row[:name] }
    end

    let(:schema) { TestTableSchema11.new }

    describe '#header' do
      subject { schema.header }

      it 'returns header columns' do
        expect(subject.shift).to eq 'ID'
        expect(subject.shift).to eq 'Name'
        expect(subject.shift).to be_nil
      end
    end

    describe '#row' do
      subject { schema.row(context: item) }

      let(:item) do
        { id: 1, name: 'Taro' }
      end

      it 'returns row columns' do
        expect(subject.shift).to eq 1
        expect(subject.shift).to eq 'Taro'
        expect(subject.shift).to be_nil
      end
    end

    describe '#column_converters' do
      subject { schema.column_converters.keys }
      it { is_expected.to eq [] }
    end

    describe '#result_builders' do
      subject { schema.result_builders.keys }
      it { is_expected.to eq [] }
    end
  end

  context 'define columns' do
    class TestTableSchema12
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

    let(:schema) do
      TestTableSchema12.new(
        context: {
          questions: [
            { id: 'Q1', text: 'Do you like sushi?' },
            { id: 'Q2', text: 'Do you like yakiniku?' },
            { id: 'Q3', text: 'Do you like ramen?' }
          ]
        }
      )
    end

    describe '#header' do
      subject { schema.header }

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

    describe '#row' do
      subject { schema.row(context: item) }

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

    describe '#column_converters' do
      subject { schema.column_converters.keys }
      it { is_expected.to eq [] }
    end

    describe '#result_builders' do
      subject { schema.result_builders.keys }
      it { is_expected.to eq [] }
    end
  end

  context 'define column_converter' do
    class TestTableSchema13
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

      column_converter :nil_to_hyphen, ->(val, *) { val.nil? ? '-' : val }
      column_converter :to_s, ->(val, *) { val.to_s }
    end

    let(:schema) do
      TestTableSchema13.new(
        context: {
          questions: [
            { id: 'Q1', text: 'Do you like sushi?' },
            { id: 'Q2', text: 'Do you like yakiniku?' },
            { id: 'Q3', text: 'Do you like ramen?' }
          ]
        }
      )
    end

    describe '#header' do
      subject { schema.header }

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

    describe '#row' do
      subject { schema.row(context: item) }

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

    describe '#column_converters' do
      subject { schema.column_converters.keys }
      it { is_expected.to eq %i[nil_to_hyphen to_s] }
    end

    describe '#result_builders' do
      subject { schema.result_builders.keys }
      it { is_expected.to eq [] }
    end
  end

  context 'define context_builder' do
    class TestTableSchema14
      include TableStructure::Schema

      TableContext = Struct.new(:questions)

      RowContext = Struct.new(:id, :name, :pets, :answers) do
        def more_pets
          pets + pets
        end
      end

      context_builder :table, ->(context) { TableContext.new(*context.values) }
      context_builder :row, ->(context) { RowContext.new(*context.values) }

      column  name: 'ID',
              value: ->(row, _table) { row.id }

      column  name: 'Name',
              value: ->(row, *) { row.name }

      columns name: ['Pet 1', 'Pet 2', 'Pet 3'],
              value: ->(row, *) { row.more_pets }

      columns lambda { |table|
        table.questions.map do |question|
          {
            name: question[:id],
            value: ->(row, *) { row.answers[question[:id]] }
          }
        end
      }

      column_converter :nil_to_hyphen, ->(val, *) { val.nil? ? '-' : val }
      column_converter :to_s, ->(val, *) { val.to_s }
    end

    let(:schema) do
      TestTableSchema14.new(
        context: {
          questions: [
            { id: 'Q1', text: 'Do you like sushi?' },
            { id: 'Q2', text: 'Do you like yakiniku?' },
            { id: 'Q3', text: 'Do you like ramen?' }
          ]
        }
      )
    end

    describe '#header' do
      subject { schema.header }

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

    describe '#row' do
      subject { schema.row(context: item) }

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

    describe '#column_converters' do
      subject { schema.column_converters.keys }
      it { is_expected.to eq %i[nil_to_hyphen to_s] }
    end

    describe '#result_builders' do
      subject { schema.result_builders.keys }
      it { is_expected.to eq [] }
    end
  end

  context 'define result_builder' do
    class TestTableSchema15
      include TableStructure::Schema

      column  name: 'ID',
              value: ->(row, *) { row[:id] }

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

      Result = Struct.new(:id, :name, :pet1, :pet2, :pet3, :q1, :q2, :q3)

      result_builder :to_struct, ->(values, *) { Result.new(*values) }
    end

    let(:schema) do
      TestTableSchema15.new(
        context: {
          questions: [
            { id: 'Q1', text: 'Do you like sushi?' },
            { id: 'Q2', text: 'Do you like yakiniku?' },
            { id: 'Q3', text: 'Do you like ramen?' }
          ]
        }
      )
    end

    describe '#header' do
      subject { schema.header }

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

    describe '#row' do
      subject { schema.row(context: item) }

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

    describe '#column_converters' do
      subject { schema.column_converters.keys }
      it { is_expected.to eq [] }
    end

    describe '#result_builders' do
      subject { schema.result_builders.keys }
      it { is_expected.to eq [:to_struct] }
    end
  end

  context 'specify result_type: :hash' do
    class TestTableSchema16
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

    let(:schema) do
      TestTableSchema16.new(
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

    describe '#header' do
      subject { schema.header }

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

    describe '#row' do
      subject { schema.row(context: item) }

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

    describe '#column_converters' do
      subject { schema.column_converters.keys }
      it { is_expected.to eq [] }
    end

    describe '#result_builders' do
      subject { schema.result_builders.keys }
      it { is_expected.to eq [:to_h] }
    end
  end

  context 'define option' do
    class TestTableSchema17
      include TableStructure::Schema

      column  name: 'ID',
              key: :id,
              value: ->(row, *) { row[:id] }

      column  name: 'Name',
              key: :name,
              value: ->(row, *) { row[:name] }

      option :result_type, :hash
    end

    let(:schema) { TestTableSchema17.new }

    describe '#header' do
      subject { schema.header }

      it 'returns header columns' do
        expect(subject[:id]).to eq 'ID'
        expect(subject[:name]).to eq 'Name'
      end
    end

    describe '#row' do
      subject { schema.row(context: item) }

      let(:item) do
        { id: 1, name: 'Taro' }
      end

      it 'returns row columns' do
        expect(subject[:id]).to eq 1
        expect(subject[:name]).to eq 'Taro'
      end
    end

    describe '#column_converters' do
      subject { schema.column_converters.keys }
      it { is_expected.to eq [] }
    end

    describe '#result_builders' do
      subject { schema.result_builders.keys }
      it { is_expected.to eq [:to_h] }
    end

    context 'overwrite by argument' do
      let(:schema) { TestTableSchema17.new(result_type: :array) }

      describe '#header' do
        subject { schema.header }

        it 'returns header columns' do
          expect(subject.shift).to eq 'ID'
          expect(subject.shift).to eq 'Name'
          expect(subject.shift).to be_nil
        end
      end

      describe '#row' do
        subject { schema.row(context: item) }

        let(:item) do
          { id: 1, name: 'Taro' }
        end

        it 'returns row columns' do
          expect(subject.shift).to eq 1
          expect(subject.shift).to eq 'Taro'
          expect(subject.shift).to be_nil
        end
      end

      describe '#column_converters' do
        subject { schema.column_converters.keys }
        it { is_expected.to eq [] }
      end

      describe '#result_builders' do
        subject { schema.result_builders.keys }
        it { is_expected.to eq [] }
      end
    end
  end
end
