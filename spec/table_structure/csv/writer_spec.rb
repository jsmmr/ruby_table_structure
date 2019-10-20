# frozen_string_literal: true

RSpec.describe TableStructure::CSV::Writer do
  module described_class::Spec
    class TestTableSchema1
      include TableStructure::Schema

      column  name: 'ID',
              key: :id,
              value: ->(row, _table) { row[:id] }

      column  name: 'Name',
              key: :name,
              value: ->(row, *) { row[:name] }
    end
  end

  let(:schema) do
    described_class::Spec::TestTableSchema1.new
  end

  let(:csv_writer) { described_class.new(schema, bom: bom) }

  let(:items) do
    [
      { id: 1, name: 'a' },
      { id: 2, name: 'b' }
    ]
  end

  describe '#write' do
    before do
      require 'csv'
      writer = double('TableStructure::Writer')

      expect(TableStructure::Writer).to receive(:new)
        .with(schema, hash_including(bom: bom)).and_return(writer)

      expect(writer).to receive(:write)
        .with(items, hash_including(to: instance_of(::CSV)))
    end

    context 'when `bom: true` is specified' do
      let(:bom) { true }
      it 'writes items' do
        array = []
        csv_writer.write(items, to: array)
        expect(array).to eq ["\uFEFF"]
      end
    end

    context 'when `bom: false` is specified' do
      let(:bom) { false }
      it 'writes items' do
        array = []
        csv_writer.write(items, to: array)
        expect(array).to eq []
      end
    end
  end
end
