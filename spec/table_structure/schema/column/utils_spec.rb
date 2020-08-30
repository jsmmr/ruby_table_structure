# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Column::Utils do
  describe '.calculate_size' do
    subject { described_class.calculate_size(values) }

    context 'when `values` is nil' do
      let(:values) { nil }
      it { is_expected.to eq 1 }
    end

    context 'when `values` is not Array' do
      let(:values) { :a }
      it { is_expected.to eq 1 }
    end

    context 'when `values` is Array' do
      context 'that is empty' do
        let(:values) { [] }
        it { is_expected.to eq 1 }
      end

      context 'that is not empty' do
        let(:values) { [:a, :b] }
        it { is_expected.to eq 2 }
      end
    end
  end

  describe '.optimize_values' do
    subject { described_class.optimize_values(values, size: size) }

    context 'when `values` is Array' do
      let(:values) { [:a, :b] }

      context 'and `size` is 1' do
        let(:size) { 1 }
        it { is_expected.to eq [:a] }
      end

      context 'and `size` is 2' do
        let(:size) { 2 }
        it { is_expected.to eq [:a, :b] }
      end

      context 'and `size` is 3' do
        let(:size) { 3 }
        it { is_expected.to eq [:a, :b, nil] }
      end
    end

    context 'when `values` is not Array' do
      let(:values) { :a }

      context 'and `size` is 1' do
        let(:size) { 1 }
        it { is_expected.to eq :a }
      end

      context 'and `size` is 2' do
        let(:size) { 2 }
        it { is_expected.to eq [:a, nil] }
      end

      context 'and `size` is 3' do
        let(:size) { 3 }
        it { is_expected.to eq [:a, nil, nil] }
      end
    end
  end
end
