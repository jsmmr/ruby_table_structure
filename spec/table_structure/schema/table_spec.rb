RSpec.describe TableStructure::Schema::Table do
  let(:table) { described_class.new(column_definitions, column_converters, result_builders, context, options) }

  describe '#columns' do
    let(:column_definitions) {
      [
        {
          name: 'ID',
          value: 1,
        },
        {
          name: 'Name',
          value: 'Taro',
        },
        {
          name: ['Pet 1', 'Pet 2', 'Pet 3'],
          value: ['cat', 'dog'],
        },
        ->(*) {
          ['Q1', 'Q2', 'Q3'].map do |question_id|
            {
              name: question_id,
              value: 'yes'
            }
          end
        }
      ]
    }
    let(:column_converters) { {} }
    let(:result_builders) { {} }
    let(:context) { nil }
    let(:options) { {} }

    let(:table_context) { context }
    let(:header_context) { nil }
    let(:row_context) { nil }

    it 'returns columns' do
      columns = table.columns
      expect(columns[0].name(header_context, table_context)).to eq 'ID'
      expect(columns[0].key).to eq nil
      expect(columns[0].value(row_context, table_context)).to eq 1
      expect(columns[0].size).to eq 1
      expect(columns[0].group_index).to eq 0

      expect(columns[1].name(header_context, table_context)).to eq 'Name'
      expect(columns[1].key).to eq nil
      expect(columns[1].value(row_context, table_context)).to eq 'Taro'
      expect(columns[1].size).to eq 1
      expect(columns[1].group_index).to eq 1

      expect(columns[2].name(header_context, table_context)).to eq ['Pet 1', 'Pet 2', 'Pet 3']
      expect(columns[2].key).to eq [nil, nil, nil]
      expect(columns[2].value(row_context, table_context)).to eq ['cat', 'dog', nil]
      expect(columns[2].size).to eq 3
      expect(columns[2].group_index).to eq 2

      expect(columns[3].name(header_context, table_context)).to eq 'Q1'
      expect(columns[3].key).to eq nil
      expect(columns[3].value(row_context, table_context)).to eq 'yes'
      expect(columns[3].size).to eq 1
      expect(columns[3].group_index).to eq 3

      expect(columns[4].name(header_context, table_context)).to eq 'Q2'
      expect(columns[4].key).to eq nil
      expect(columns[4].value(row_context, table_context)).to eq 'yes'
      expect(columns[4].size).to eq 1
      expect(columns[4].group_index).to eq 3

      expect(columns[5].name(header_context, table_context)).to eq 'Q3'
      expect(columns[5].key).to eq nil
      expect(columns[5].value(row_context, table_context)).to eq 'yes'
      expect(columns[5].size).to eq 1
      expect(columns[5].group_index).to eq 3
    end
  end

end
