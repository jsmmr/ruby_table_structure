# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Table do
  let(:table) do
    TableStructure::Schema::Definition.new(
      'TestTableSchema',
      column_definitions,
      context_builders,
      column_converters,
      result_builders,
      context,
      options
    ).create_table
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
      lambda do |table|
        table[:questions].map do |question|
          {
            name: question[:id],
            key: question[:id].downcase,
            value: ->(row, *) { row[:answers][question[:id]] }
          }
        end
      end,
      ->(table) { described_class::Spec::NestedTestTableSchema.new(context: table, **nested_schema_options) }
    ]
  end

  let(:context_builders) { {} }

  let(:context) do
    {
      questions: [
        { id: 'Q1', text: 'Do you like sushi?' },
        { id: 'Q2', text: 'Do you like yakiniku?' },
        { id: 'Q3', text: 'Do you like ramen?' }
      ]
    }
  end

  describe '#header' do
    let(:column_converters) { {} }
    let(:result_builders) { {} }

    let(:header_context) { nil }

    let(:options) { {} }

    subject { table.header(context: header_context) }

    context 'when option is not specified' do
      let(:nested_schema_options) { {} }

      it { is_expected.to eq ['ID', 'Name', 'Pet 1', 'Pet 2', 'Pet 3', 'Q1', 'Q2', 'Q3', 'ID', 'Name', 'Pet 1', 'Pet 2', 'Pet 3', 'Q1', 'Q2', 'Q3'] }
    end

    context 'when :name_prefix option is specified' do
      let(:nested_schema_options) { { name_prefix: 'p ' } }

      it { is_expected.to eq ['ID', 'Name', 'Pet 1', 'Pet 2', 'Pet 3', 'Q1', 'Q2', 'Q3', 'p ID', 'p Name', 'p Pet 1', 'p Pet 2', 'p Pet 3', 'p Q1', 'p Q2', 'p Q3'] }
    end

    context 'when :name_suffix option is specified' do
      let(:nested_schema_options) { { name_suffix: ' s' } }

      it { is_expected.to eq ['ID', 'Name', 'Pet 1', 'Pet 2', 'Pet 3', 'Q1', 'Q2', 'Q3', 'ID s', 'Name s', 'Pet 1 s', 'Pet 2 s', 'Pet 3 s', 'Q1 s', 'Q2 s', 'Q3 s'] }
    end

    context 'when both :name_prefix and :key_suffix options are specified' do
      let(:nested_schema_options) { { name_prefix: 'p ', name_suffix: ' s' } }

      it { is_expected.to eq ['ID', 'Name', 'Pet 1', 'Pet 2', 'Pet 3', 'Q1', 'Q2', 'Q3', 'p ID s', 'p Name s', 'p Pet 1 s', 'p Pet 2 s', 'p Pet 3 s', 'p Q1 s', 'p Q2 s', 'p Q3 s'] }
    end
  end

  describe '#row' do
    let(:column_converters) { {} }
    let(:result_builders) { {} }

    let(:options) { {} }
    let(:nested_schema_options) { {} }

    let(:row_context) { { id: 1, name: 'Taro', pets: %w[cat dog], answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' } } }

    subject { table.row(context: row_context) }

    it { is_expected.to eq [1, 'Taro', 'cat', 'dog', nil, 'yes', 'no', 'yes', 1, 'Taro', 'cat', 'dog', nil, 'yes', 'no', 'yes'] }
  end

  describe '#rows' do
    let(:column_converters) { {} }
    let(:result_builders) { {} }

    let(:options) { {} }
    let(:nested_schema_options) { {} }

    let(:items) { [{ id: 1, name: 'Taro', pets: %w[cat dog], answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' } }] }

    subject { table.rows(items).first }

    it { is_expected.to eq [1, 'Taro', 'cat', 'dog', nil, 'yes', 'no', 'yes', 1, 'Taro', 'cat', 'dog', nil, 'yes', 'no', 'yes'] }
  end

  describe '#keys' do
    let(:column_converters) { {} }
    let(:result_builders) { {} }

    let(:nested_schema_options) { {} }

    subject { table.send(:keys) }

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
end
