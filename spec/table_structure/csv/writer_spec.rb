# frozen_string_literal: true

RSpec.describe TableStructure::CSV::Writer do
  let(:schema) do
    ::Micro::UserTableSchema.new
  end

  let(:inner_writer_options) do
    [
      { header_omitted: false, header_context: {} },
      { header_context: {} },
      { header: { context: {} } }
    ].sample
  end

  let(:csv_writer) do
    described_class.new(schema, **inner_writer_options.merge(csv_writer_options))
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
        .with(schema, header: { context: {} })
        .and_return(writer)

      expect(writer).to receive(:write)
        .with(items, to: instance_of(::CSV), header: { context: {} }) do |&block|
          expect(block).to eq handler
        end
    end

    let(:output) { [] }

    context 'when `bom: true` is specified' do
      let(:csv_writer_options) { { bom: true } }
      it 'writes items' do
        csv_writer.write(items, to: output, **inner_writer_options, &handler)
        expect(output).to eq ["\uFEFF"]
      end
    end

    context 'when `bom: false` is specified' do
      let(:csv_writer_options) { { bom: false } }
      it 'writes items' do
        csv_writer.write(items, to: output, **inner_writer_options, &handler)
        expect(output).to be_empty
      end
    end

    context 'when `csv_options` is specified' do
      let(:csv_options) { { col_sep: ',' } }
      let(:csv_writer_options) { { csv_options: csv_options } }
      it 'passes specified csv_options' do
        expect(::CSV).to receive(:new)
          .with(output, **csv_options)
          .and_call_original

        csv_writer.write(items, to: output, **inner_writer_options, &handler)
      end
    end
  end
end
