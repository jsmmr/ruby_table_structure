# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Table::ContextBuilder do
  let(:context_builder) { described_class.new(method, callable) }

  describe '#header' do
    let(:method) { :header }
    let(:callable) { ->(context) { context } }

    subject do
      c = Class.new do
        def header(context:)
          "#{context}_result1"
        end
      end
      c.new.extend(context_builder)
    end

    it { expect(subject.respond_to?(method)).to be_truthy }
    it { expect(subject.header(context: 'header')).to eq 'header_result1' }
  end

  describe '#row' do
    let(:method) { :row }
    let(:callable) { ->(context) { context } }

    subject do
      c = Class.new do
        def row(context:)
          "#{context}_result2"
        end
      end
      c.new.extend(context_builder)
    end

    it { expect(subject.respond_to?(method)).to be_truthy }
    it { expect(subject.row(context: 'row')).to eq 'row_result2' }
  end
end
