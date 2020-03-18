# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Columns::Schema do
  let(:schema) { double('TestTableSchema') }
  let(:table) { double('TableStructure::Table') }
  let(:column) { described_class.new(schema) }

  before do
    allow(::TableStructure::Table).to receive(:new).and_return(table)
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

  describe '#contain_callable?' do
    let(:attribute) { 'attribute' }

    it 'delegates to table' do
      expect(schema).to receive(:contain_callable?).with(attribute)
      column.contain_callable?(attribute)
    end
  end
end
