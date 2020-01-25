# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Table do
  let(:table) do
    described_class.new(
      columns: [
        ::TableStructure::Schema::Columns::Attributes.new(
          name: 'ID',
          key: 'id',
          value: 1,
          size: 1
        ),
        ::TableStructure::Schema::Columns::Attributes.new(
          name: 'Name',
          key: :name,
          value: 'Taro',
          size: 1
        ),
        ::TableStructure::Schema::Columns::Schema.new(
          ::TableStructure::Schema.create_class do
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
          end.new(context: context, **nested_schema_options)
        )
      ],
      context: context,
      keys_generator: ::TableStructure::Schema::KeysGenerator.new(
        **keys_generator_options
      )
    )
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

  describe '#header' do
    let(:header_context) { nil }

    let(:keys_generator_options) { {} }

    subject { table.header(context: header_context) }

    context 'when option is not specified' do
      let(:nested_schema_options) { {} }

      it { is_expected.to eq ['ID', 'Name', 'Pet 1', 'Pet 2', 'Pet 3', 'Q1', 'Q2', 'Q3'] }
    end

    context 'when :name_prefix option is specified' do
      let(:nested_schema_options) { { name_prefix: 'p ' } }

      it { is_expected.to eq ['ID', 'Name', 'p Pet 1', 'p Pet 2', 'p Pet 3', 'p Q1', 'p Q2', 'p Q3'] }
    end

    context 'when :name_suffix option is specified' do
      let(:nested_schema_options) { { name_suffix: ' s' } }

      it { is_expected.to eq ['ID', 'Name', 'Pet 1 s', 'Pet 2 s', 'Pet 3 s', 'Q1 s', 'Q2 s', 'Q3 s'] }
    end

    context 'when both :name_prefix and :key_suffix options are specified' do
      let(:nested_schema_options) { { name_prefix: 'p ', name_suffix: ' s' } }

      it { is_expected.to eq ['ID', 'Name', 'p Pet 1 s', 'p Pet 2 s', 'p Pet 3 s', 'p Q1 s', 'p Q2 s', 'p Q3 s'] }
    end
  end

  # deprecated
  describe '#row' do
    let(:keys_generator_options) { {} }
    let(:nested_schema_options) { {} }

    let(:row_context) { { id: 1, name: 'Taro', pets: %w[cat dog], answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' } } }

    subject { table.row(context: row_context) }

    it { is_expected.to eq [1, 'Taro', 'cat', 'dog', nil, 'yes', 'no', 'yes'] }
  end

  describe '#rows' do
    let(:keys_generator_options) { {} }
    let(:nested_schema_options) { {} }

    let(:items) { [{ id: 1, name: 'Taro', pets: %w[cat dog], answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' } }] }

    subject { table.rows(items).first }

    it { is_expected.to eq [1, 'Taro', 'cat', 'dog', nil, 'yes', 'no', 'yes'] }
  end

  describe '#keys' do
    let(:nested_schema_options) { {} }

    subject { table.send(:keys) }

    # Nested schema does not have keys
    context 'when option is not specified' do
      let(:keys_generator_options) { {} }
      it { is_expected.to eq ['id', :name, nil, nil, nil, nil, nil, nil] }
    end

    context 'when :key_prefix option is specified' do
      let(:keys_generator_options) { { prefix: 'p_' } }

      it { is_expected.to eq ['p_id', :p_name, nil, nil, nil, nil, nil, nil] }
    end

    context 'when :key_suffix option is specified' do
      let(:keys_generator_options) { { suffix: :_s } }

      it { is_expected.to eq ['id_s', :name_s, nil, nil, nil, nil, nil, nil] }
    end

    context 'when both :key_prefix and :key_suffix options are specified' do
      let(:keys_generator_options) { { prefix: :p_, suffix: '_s' } }

      it { is_expected.to eq ['p_id_s', :p_name_s, nil, nil, nil, nil, nil, nil] }
    end
  end
end
