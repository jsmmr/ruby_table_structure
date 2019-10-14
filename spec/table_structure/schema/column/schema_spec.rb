# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Column::Schema do
  module described_class::Spec
    class TestTableSchema1
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

      column  nil
      column  ->(*) { nil }

      columns [nil, nil]
      columns ->(*) { [nil, nil] }

      columns []
      columns ->(*) { [] }

      column_converter :nil_to_hyphen, ->(val, *) { val.nil? ? '-' : val }
      column_converter :to_s, ->(val, *) { val.to_s }
    end
  end

  context 'pattern 1' do
    let(:schema) do
      described_class::Spec::TestTableSchema1.new(
        context: {
          questions: [
            { id: 'Q1', text: 'Do you like sushi?' },
            { id: 'Q2', text: 'Do you like yakiniku?' },
            { id: 'Q3', text: 'Do you like ramen?' }
          ]
        }
      )
    end
    let(:column) { described_class.new(schema) }

    describe '#name' do
      subject { column.name(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['ID', 'Name', 'Pet 1', 'Pet 2', 'Pet 3', 'Q1', 'Q2', 'Q3'] }
    end

    describe '#keys' do
      subject { column.keys }

      it { is_expected.to eq %i[id name pet1 pet2 pet3 q1 q2 q3] }
    end

    describe '#value' do
      subject { column.value(row_context, table_context) }

      let(:row_context) do
        { id: 1, name: 'Taro', pets: %w[cat dog], answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' } }
      end
      let(:table_context) { nil }

      it { is_expected.to eq ['1', 'Taro', 'cat', 'dog', '-', 'yes', 'no', 'yes'] }
    end

    describe '#size' do
      subject { column.size }

      it { is_expected.to eq 8 }
    end
  end
end
