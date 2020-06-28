# frozen_string_literal: true

RSpec.describe TableStructure::Schema::RowContextBuilderFactory do
  let(:factory) { described_class.new(schema, builders) }

  let(:schema) { double('TableStructure::Schema') }

  let(:some_builders) do
    {
      header: proc { |context| context[:id] * 2 },
      row: proc { |context| context[:id] * 3 }
    }
  end

  let(:no_builders) { {} }

  describe '#create_header_builder' do
    let(:context) { { id: 1 } }

    let(:header_builder) { factory.create_header_builder }

    before { expect(schema).to receive(:contain_callable?).with(:name).and_return(contain_callable) }

    context 'when schema contains callable' do
      let(:contain_callable) { true }

      context 'and builders exist' do
        let(:builders) { some_builders }
        subject { header_builder.call(context) }
        it { is_expected.to eq 2 }
      end

      context 'and builders do not exist' do
        let(:builders) { no_builders }
        subject { header_builder }
        it { is_expected.to be_nil }
      end
    end

    context 'when schema does not contain callable' do
      let(:contain_callable) { false }
      let(:builders) { [some_builders, no_builders].sample }
      subject { header_builder }
      it { is_expected.to be_nil }
    end
  end

  describe '#create_data_builder' do
    let(:context) { { id: 2 } }

    let(:data_builder) { factory.create_data_builder }

    before { expect(schema).to receive(:contain_callable?).with(:value).and_return(contain_callable) }

    context 'when schema contains callable' do
      let(:contain_callable) { true }

      context 'and builders exist' do
        let(:builders) { some_builders }
        subject { data_builder.call(context) }
        it { is_expected.to eq 6 }
      end

      context 'and builders do not exist' do
        let(:builders) { no_builders }
        subject { data_builder }
        it { is_expected.to be_nil }
      end
    end

    context 'when schema does not contain callable' do
      let(:contain_callable) { false }
      let(:builders) { [some_builders, no_builders].sample }
      subject { data_builder }
      it { is_expected.to be_nil }
    end
  end
end
