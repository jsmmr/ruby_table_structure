# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Table::ContextBuilder do
  let(:context_builder) { described_class.new(overrides) }

  let(:overrides) do
    [
      { method: :header, callable: header_callable },
      { method: :row, callable: row_callable }
    ]
  end

  let(:header_callable) { ->(context) { "#{context}_result" } }
  let(:header_context) { :header_context }

  let(:row_callable) { ->(context) { "#{context}_result" } }
  let(:row_context) { :row_context }

  let(:table) do
    Class.new do
      def header(context:)
        "#{context}_1"
      end

      def row(context:)
        "#{context}_2"
      end
    end
         .new.extend(context_builder)
  end

  describe '#header' do
    before do
      expect(header_callable).to receive(:call)
        .with(header_context)
        .and_call_original
    end

    it { expect(table.header(context: header_context)).to eq 'header_context_result_1' }
  end

  describe '#row' do
    before do
      expect(row_callable).to receive(:call)
        .with(row_context)
        .and_call_original
    end

    it { expect(table.row(context: row_context)).to eq 'row_context_result_2' }
  end
end
