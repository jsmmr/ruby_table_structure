# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Table do
  let(:table) { described_class.new(column_definitions, column_converters, result_builders, context, options) }

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
        lambda do |*|
          %w[Q1 Q2 Q3].map do |question_id|
            {
              name: question_id,
              value: 'yes'
            }
          end
        end
      ]
    end
    let(:column_converters) { {} }
    let(:result_builders) { {} }
    let(:context) { nil }
    let(:options) { {} }

    let(:table_context) { context }
    let(:header_context) { nil }
    let(:row_context) { nil }

    subject { table.columns.size }

    it { is_expected.to eq 6 }
  end
end
