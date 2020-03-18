# frozen_string_literal: true

RSpec.describe TableStructure::Schema::KeyConverter do
  describe '#convert' do
    subject { described_class.new(**options).convert(keys) }

    let(:keys) { [:a, 'b', nil, '', 1] }

    context 'no options' do
      let(:options) { {} }

      it { is_expected.to eq [:a, 'b', nil, '', 1] }
    end

    context ':prefix option is specified' do
      let(:options) { { prefix: 'p_' } }

      it { is_expected.to eq [:p_a, 'p_b', nil, 'p_', 'p_1'] }
    end

    context ':suffix option is specified' do
      let(:options) { { suffix: '_s' } }

      it { is_expected.to eq [:a_s, 'b_s', nil, '_s', '1_s'] }
    end

    context ':prefix and :suffix options are specified' do
      let(:options) { { prefix: 'p_', suffix: '_s' } }

      it { is_expected.to eq [:p_a_s, 'p_b_s', nil, 'p__s', 'p_1_s'] }
    end
  end
end
