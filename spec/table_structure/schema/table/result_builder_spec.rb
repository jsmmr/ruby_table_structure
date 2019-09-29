# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Table::ResultBuilder do
  let(:result_builder) { described_class.new(overrides, keys: keys, context: table_context) }

  let(:overrides) do
    [
      { method: :header, callables: { test: header_callable } },
      { method: :row, callables: { test: row_callable } }
    ]
  end

  let(:keys) { %i[a b c] }
  let(:table_context) { :table_context }

  let(:header_callable) { spy('header_callable', call: %w[d e f]) }
  let(:header_context) { :header_context }

  let(:row_callable) { spy('row_callable', call: [4, 5, 6]) }
  let(:row_context) { :row_context }

  let(:table) do
    Class.new do
      def header(context:)
        %w[a b c]
      end

      def row(context:)
        [1, 2, 3]
      end
    end
         .new.extend(result_builder)
  end

  describe '#header' do
    before do
      expect(header_callable).to receive(:call)
        .with(%w[a b c], keys, header_context, table_context)
    end

    it { expect(table.header(context: header_context)).to eq %w[d e f] }
  end

  describe '#row' do
    before do
      expect(row_callable).to receive(:call)
        .with([1, 2, 3], keys, row_context, table_context)
    end

    it { expect(table.row(context: row_context)).to eq [4, 5, 6] }
  end
end
