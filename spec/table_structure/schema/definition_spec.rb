# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Definition do
  let(:table) do
    described_class.new(
      name,
      column_definitions,
      context_builders,
      column_converters,
      result_builders,
      context,
      options
    )
  end

  module described_class::Spec
    class NestedTestTableSchema
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

  let(:name) { 'TestTableSchema' }

  describe '#columns' do
    let(:column_definitions) do
      [
        {
          name: 'ID',
          value: 1
        },
        {
          name: 'Name',
          value: 'Taro'
        },
        {
          name: ['Pet 1', 'Pet 2', 'Pet 3'],
          value: %w[cat dog]
        },
        lambda do |table|
          table[:questions].map do |question|
            {
              name: question[:id],
              value: ->(row, *) { row[:answers][question[:id]] }
            }
          end
        end,
        ->(table) { described_class::Spec::NestedTestTableSchema.new(context: table) }
      ]
    end
    let(:context_builders) { {} }
    let(:column_converters) { {} }
    let(:result_builders) { {} }
    let(:context) do
      {
        questions: [
          { id: 'Q1', text: 'Do you like sushi?' },
          { id: 'Q2', text: 'Do you like yakiniku?' },
          { id: 'Q3', text: 'Do you like ramen?' }
        ]
      }
    end
    let(:options) { {} }

    let(:table_context) { context }
    let(:header_context) { nil }
    let(:row_context) { nil }

    subject { table.columns.size }

    it { is_expected.to eq 7 }
  end
end
