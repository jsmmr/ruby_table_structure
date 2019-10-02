# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Table::ColumnConverter do
  let(:result_builder) { described_class.new(overrides, context: table_context) }

  let(:overrides) do
    [
      { method: :header, callables: { test: header_callable } },
      { method: :row, callables: { test: row_callable } }
    ]
  end

  let(:keys) { %i[a b c] }
  let(:table_context) { :table_context }

  let(:header_callable) { ->(val, _row, _table) { "<#{val}>" } }
  let(:header_context) { :header_context }

  let(:row_callable) { ->(val, _row, _table) { val * val } }
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
        .with(kind_of(String), header_context, table_context)
        .exactly(3).times
        .and_call_original
    end

    it { expect(table.header(context: header_context)).to eq %w[<a> <b> <c>] }
  end

  describe '#row' do
    before do
      expect(row_callable).to receive(:call)
        .with(kind_of(Numeric), row_context, table_context)
        .exactly(3).times
        .and_call_original
    end

    it { expect(table.row(context: row_context)).to eq [1, 4, 9] }
  end
end
