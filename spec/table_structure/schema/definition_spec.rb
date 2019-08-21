# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Definition do
  let(:options) { {} }

  context 'pattern 1' do
    let(:definitions) do
      [
        {}
      ]
    end

    let(:compiled_definitions) { described_class.new(definitions, options).compile }

    describe '#size' do
      subject { compiled_definitions.size }
      it { is_expected.to eq 1 }
    end

    describe '#name' do
      subject { compiled_definitions[0][:name] }
      it { is_expected.to be_nil }
    end

    describe '#key' do
      subject { compiled_definitions[0][:key] }
      it { is_expected.to be_nil }
    end

    describe '#value' do
      subject { compiled_definitions[0][:value] }
      it { is_expected.to be_nil }
    end

    describe '#size' do
      subject { compiled_definitions[0][:size] }
      it { is_expected.to eq 1 }
    end
  end

  context 'pattern 2' do
    let(:definitions) do
      [
        {
        name: 'Name',
        key: :name,
        value: 'Taro',
        size: 1
      }
    ]
    end

    let(:compiled_definitions) { described_class.new(definitions, options).compile }

    describe '#size' do
      subject { compiled_definitions.size }
      it { is_expected.to eq 1 }
    end

    describe '#name' do
      subject { compiled_definitions[0][:name] }
      it { is_expected.to eq 'Name' }
    end

    describe '#key' do
      subject { compiled_definitions[0][:key] }
      it { is_expected.to eq :name }
    end

    describe '#value' do
      subject { compiled_definitions[0][:value] }
      it { is_expected.to eq 'Taro' }
    end

    describe '#size' do
      subject { compiled_definitions[0][:size] }
      it { is_expected.to eq 1 }
    end
  end

  context 'pattern 3' do
    let(:definitions) do
      [
        {
          name: ['Pet 1', 'Pet 2', 'Pet 3']
        }
      ]
    end

    let(:compiled_definitions) { described_class.new(definitions, options).compile }

    describe '#size' do
      subject { compiled_definitions.size }
      it { is_expected.to eq 1 }
    end

    describe '#name' do
      subject { compiled_definitions[0][:name] }
      it { is_expected.to eq ['Pet 1', 'Pet 2', 'Pet 3'] }
    end

    describe '#key' do
      subject { compiled_definitions[0][:key] }
      it { is_expected.to be_nil }
    end

    describe '#value' do
      subject { compiled_definitions[0][:value] }
      it { is_expected.to be_nil }
    end

    describe '#size' do
      subject { compiled_definitions[0][:size] }
      it { is_expected.to eq 3 }
    end
  end

  context 'pattern 4' do
    let(:definitions) do
      [
        {
          key: %i[pet1 pet2 pet3]
        }
      ]
    end

    let(:compiled_definitions) { described_class.new(definitions, options).compile }

    describe '#size' do
      subject { compiled_definitions.size }
      it { is_expected.to eq 1 }
    end

    describe '#name' do
      subject { compiled_definitions[0][:name] }
      it { is_expected.to be_nil }
    end

    describe '#key' do
      subject { compiled_definitions[0][:key] }
      it { is_expected.to eq %i[pet1 pet2 pet3] }
    end

    describe '#value' do
      subject { compiled_definitions[0][:value] }
      it { is_expected.to be_nil }
    end

    describe '#size' do
      subject { compiled_definitions[0][:size] }
      it { is_expected.to eq 3 }
    end
  end

  context 'pattern 5' do
    let(:definitions) do
      [
        {
          name: ['Pet 1', 'Pet 2', 'Pet 3'],
          key: %i[pet1 pet2]
        }
      ]
    end

    let(:compiled_definitions) { described_class.new(definitions, options).compile }

    describe '#size' do
      subject { compiled_definitions.size }
      it { is_expected.to eq 1 }
    end

    describe '#name' do
      subject { compiled_definitions[0][:name] }
      it { is_expected.to eq ['Pet 1', 'Pet 2', 'Pet 3'] }
    end

    describe '#key' do
      subject { compiled_definitions[0][:key] }
      it { is_expected.to eq %i[pet1 pet2] }
    end

    describe '#value' do
      subject { compiled_definitions[0][:value] }
      it { is_expected.to be_nil }
    end

    describe '#size' do
      subject { compiled_definitions[0][:size] }
      it { is_expected.to eq 3 }
    end
  end

  context 'pattern 6' do
    let(:definitions) do
      [
        {
          name: ['Pet 1', 'Pet 2', 'Pet 3'],
          key: %i[pet1 pet2 pet3]
        }
      ]
    end

    let(:compiled_definitions) { described_class.new(definitions, options).compile }

    describe '#size' do
      subject { compiled_definitions.size }
      it { is_expected.to eq 1 }
    end

    describe '#name' do
      subject { compiled_definitions[0][:name] }
      it { is_expected.to eq ['Pet 1', 'Pet 2', 'Pet 3'] }
    end

    describe '#key' do
      subject { compiled_definitions[0][:key] }
      it { is_expected.to eq %i[pet1 pet2 pet3] }
    end

    describe '#value' do
      subject { compiled_definitions[0][:value] }
      it { is_expected.to be_nil }
    end

    describe '#size' do
      subject { compiled_definitions[0][:size] }
      it { is_expected.to eq 3 }
    end
  end

  context 'pattern 7' do
    let(:definitions) do
      [
        {
          name: ['Pet 1', 'Pet 2'],
          key: %i[pet1 pet2 pet3],
          size: 4
        }
      ]
    end

    let(:compiled_definitions) { described_class.new(definitions, options).compile }

    describe '#size' do
      subject { compiled_definitions.size }
      it { is_expected.to eq 1 }
    end

    describe '#name' do
      subject { compiled_definitions[0][:name] }
      it { is_expected.to eq ['Pet 1', 'Pet 2'] }
    end

    describe '#key' do
      subject { compiled_definitions[0][:key] }
      it { is_expected.to eq %i[pet1 pet2 pet3] }
    end

    describe '#value' do
      subject { compiled_definitions[0][:value] }
      it { is_expected.to be_nil }
    end

    describe '#size' do
      subject { compiled_definitions[0][:size] }
      it { is_expected.to eq 4 }
    end
  end

  context 'pattern 7' do
    let(:definitions) do
      [
        {
          name: 'ID',
          value: 1
        },
        {
          name: 'Name',
          value: 'Taro'
        },
        {
          name: ['Pet 1', 'Pet 2', 'Pet 3'],
          value: %w[cat dog]
        },
        lambda do |*|
          %w[Q1 Q2 Q3].map do |question_id|
            {
              name: question_id,
              value: 'yes'
            }
          end
        end
      ]
    end

    let(:compiled_definitions) { described_class.new(definitions, options).compile }

    describe '#size' do
      subject { compiled_definitions.size }
      it { is_expected.to eq 6 }
    end
  end
end
