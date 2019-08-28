# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Table do
  let(:table) { described_class.new(column_definitions, column_converters, result_builders, context, options) }

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

  describe '#header_values' do
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
        ->(table) { NestedTestTableSchema.new(context: table) }
      ]
    end
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

    let(:header_context) { nil }
    let(:row_context) { nil }

    subject { table.header_values(header_context) }

    it { is_expected.to eq ['ID', 'Name', 'Pet 1', 'Pet 2', 'Pet 3', 'Q1', 'Q2', 'Q3', 'ID', 'Name', 'Pet 1', 'Pet 2', 'Pet 3', 'Q1', 'Q2', 'Q3'] }
  end

  describe '#row_values' do
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
        ->(table) { NestedTestTableSchema.new(context: table) }
      ]
    end
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

    let(:header_context) { nil }
    let(:row_context) { { id: 1, name: 'Taro', pets: %w[cat dog], answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' } } }

    subject { table.row_values(row_context) }

    it { is_expected.to eq [1, 'Taro', 'cat', 'dog', nil, 'yes', 'no', 'yes', 1, 'Taro', 'cat', 'dog', nil, 'yes', 'no', 'yes'] }
  end

  describe '#keys' do
    let(:column_definitions) do
      [
        {
          name: 'ID',
          key: 'id',
          value: 1
        },
        {
          name: 'Name',
          key: 1,
          value: 'Taro'
        },
        {
          name: ['Pet 1', 'Pet 2', 'Pet 3'],
          key: %i[pet1 pet2 pet3],
          value: %w[cat dog]
        },
        lambda do |*|
          %w[Q1 Q2 Q3].map do |question_id|
            {
              name: question_id,
              key: question_id.downcase,
              value: 'yes'
            }
          end
        end,
        ->(table) { NestedTestTableSchema.new(context: table) }
      ]
    end
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

    let(:header_context) { nil }
    let(:row_context) { nil }

    subject { table.keys }

    # Nested schema does not have defined key
    context 'when option is not specified' do
      let(:options) { {} }
      it { is_expected.to eq ['id', 1, :pet1, :pet2, :pet3, 'q1', 'q2', 'q3', nil, nil, nil, nil, nil, nil, nil, nil] }
    end

    context 'when :key_prefix option is specified' do
      let(:options) { { key_prefix: 'p_' } }

      it { is_expected.to eq ['p_id', 'p_1', :p_pet1, :p_pet2, :p_pet3, 'p_q1', 'p_q2', 'p_q3', nil, nil, nil, nil, nil, nil, nil, nil] }
    end

    context 'when :key_suffix option is specified' do
      let(:options) { { key_suffix: :_s } }

      it { is_expected.to eq ['id_s', '1_s', :pet1_s, :pet2_s, :pet3_s, 'q1_s', 'q2_s', 'q3_s', nil, nil, nil, nil, nil, nil, nil, nil] }
    end

    context 'when both :key_prefix and :key_suffix options are specified' do
      let(:options) { { key_prefix: :p_, key_suffix: '_s' } }

      it { is_expected.to eq ['p_id_s', 'p_1_s', :p_pet1_s, :p_pet2_s, :p_pet3_s, 'p_q1_s', 'p_q2_s', 'p_q3_s', nil, nil, nil, nil, nil, nil, nil, nil] }
    end
  end

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
