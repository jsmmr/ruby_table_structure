# frozen_string_literal: true

RSpec.describe TableStructure::Table::Iterator do
  describe '#iterate' do
    let(:iterator) { described_class.new(table, **options) }
    let(:table) { double('TableStructure::Schema::Table') }
    let(:enum) { iterator.iterate(items) }
    let(:items) { ['body'] }

    context 'when header is enabled without context' do
      let(:options) { { header: [true, {}].sample } }

      it 'iterates converted rows' do
        expect(table).to receive(:header).with(context: nil).and_return('header')
        expect(table).to receive(:body).with(items).and_return(items)
        expect(enum.next).to eq 'header'
        expect(enum.next).to eq 'body'
        expect { enum.next }.to raise_error(::StopIteration)
      end
    end

    context 'when header is enabled with context' do
      let(:options) { { header: { context: 'context' } } }

      it 'iterates converted rows' do
        expect(table).to receive(:header).with(context: 'context').and_return('header')
        expect(table).to receive(:body).with(items).and_return(items)
        expect(enum.next).to eq 'header'
        expect(enum.next).to eq 'body'
        expect { enum.next }.to raise_error(::StopIteration)
      end
    end
  end
end
