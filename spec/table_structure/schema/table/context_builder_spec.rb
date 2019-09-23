# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Table::ContextBuilder do
  let(:context_builder) { described_class.new(name, callable) }

  describe '#available?' do
    subject { context_builder }

    let(:name) { :any }

    context 'when callable is nil' do
      let(:callable) { nil }

      it { is_expected.not_to be_available }
    end

    context 'when callable is not nil' do
      let(:callable) { ->(context) { context } }

      it { is_expected.to be_available }
    end
  end

  describe '#header' do
    let(:name) { :header }
    let(:callable) { ->(context) { context } }

    subject do
      c = Class.new do
        def header(context:)
          "#{context}_result1"
        end
      end
      c.new.extend(context_builder)
    end

    it { expect(subject.respond_to?(name)).to be_truthy }
    it { expect(subject.header(context: 'header')).to eq 'header_result1' }
  end

  describe '#row' do
    let(:name) { :row }
    let(:callable) { ->(context) { context } }

    subject do
      c = Class.new do
        def row(context:)
          "#{context}_result2"
        end
      end
      c.new.extend(context_builder)
    end

    it { expect(subject.respond_to?(name)).to be_truthy }
    it { expect(subject.row(context: 'row')).to eq 'row_result2' }
  end
end
