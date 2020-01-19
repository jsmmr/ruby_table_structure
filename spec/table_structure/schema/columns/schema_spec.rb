# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Columns::Schema do
  let(:schema) { double('TestTableSchema') }
  let(:table) { double('TableStructure::Schema::Table') }
  let(:column) { described_class.new(schema) }

  before do
    expect(schema).to receive(:create_table).and_return(table)
  end

  describe '#names' do
    let(:row_context) { 'row_context' }
    let(:table_context) { 'table_context' }

    it 'delegates to table' do
      expect(table).to receive(:header).with(context: row_context)
      column.names(row_context, table_context)
    end
  end

  describe '#keys' do
    it 'delegates to table' do
      expect(table).to receive(:keys)
      column.keys
    end
  end

  describe '#values' do
    let(:row_context) { 'row_context' }
    let(:table_context) { 'table_context' }

    it 'delegates to table' do
      expect(table).to receive(:data).with(context: row_context)
      column.values(row_context, table_context)
    end
  end

  describe '#size' do
    it 'delegates to table' do
      expect(table).to receive(:size)
      column.size
    end
  end
end
