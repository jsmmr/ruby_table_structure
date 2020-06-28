# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Columns::Schema do
  let(:schema) { double('TestTableSchema') }
  let(:column) { described_class.new(schema) }

  before do
    expect(schema).to receive(:create_header_row_generator).and_return(proc { { result: :header } })
    expect(schema).to receive(:create_data_row_generator).and_return(proc { { result: :data } })
  end

  describe '#names' do
    let(:row_context) { 'row_context' }
    let(:table_context) { 'table_context' }

    subject { column.names(row_context, table_context) }

    it { is_expected.to eq [:header] }
  end

  describe '#keys' do
    it 'delegates to schema' do
      expect(schema).to receive(:columns_keys)
      column.keys
    end
  end

  describe '#values' do
    let(:row_context) { 'row_context' }
    let(:table_context) { 'table_context' }

    subject { column.values(row_context, table_context) }

    it { is_expected.to eq [:data] }
  end

  describe '#size' do
    it 'delegates to schema' do
      expect(schema).to receive(:columns_size)
      column.size
    end
  end

  describe '#contain_callable?' do
    let(:attribute) { 'attribute' }

    it 'delegates to schema' do
      expect(schema).to receive(:contain_callable?).with(attribute)
      column.contain_callable?(attribute)
    end
  end
end
