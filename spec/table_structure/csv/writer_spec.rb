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

  let(:inner_writer_options) { { header_omitted: [true, false].sample } }

  let(:csv_writer) do
    described_class.new(schema, **csv_writer_options, **inner_writer_options)
  end

  let(:handler) { ->(values) { values } }

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
        .with(schema, inner_writer_options)
        .and_return(writer)

      expect(writer).to receive(:write)
        .with(items, hash_including(to: instance_of(::CSV))) do |&block|
          expect(block).to eq handler
        end
    end

    let(:output) { [] }

    context 'when `bom: true` is specified' do
      let(:csv_writer_options) { { bom: true } }
      it 'writes items' do
        csv_writer.write(items, to: output, &handler)
        expect(output).to eq ["\uFEFF"]
      end
    end

    context 'when `bom: false` is specified' do
      let(:csv_writer_options) { { bom: false } }
      it 'writes items' do
        csv_writer.write(items, to: output, &handler)
        expect(output).to be_empty
      end
    end

    context 'when `csv_options` is specified' do
      let(:csv_options) { { col_sep: ',' } }
      let(:csv_writer_options) { { csv_options: csv_options } }
      it 'passes specified csv_options' do
        expect(::CSV).to receive(:new)
          .with(output, csv_options)
          .and_call_original

        csv_writer.write(items, to: output, &handler)
      end
    end

    context 'when `csv_options` is not specified' do
      let(:csv_writer_options) { {} }
      it 'passes default csv_options' do
        expect(::CSV).to receive(:new)
          .with(output, {})
          .and_call_original

        csv_writer.write(items, to: output, &handler)
      end
    end
  end
end
