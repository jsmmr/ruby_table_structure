# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Definition do
  let(:options) { {} }

  describe '#compile' do
    context 'pattern 1' do
      let(:definitions) do
        [
          {}
        ]
      end

      subject { described_class.new(definitions, options).compile }

      it 'compiles definitions' do
        expect(subject.size).to eq 1
        expect(subject[0][:name]).to be_nil
        expect(subject[0][:key]).to be_nil
        expect(subject[0][:value]).to be_nil
        expect(subject[0][:size]).to eq 1
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

      subject { described_class.new(definitions, options).compile }

      it 'compiles definitions' do
        expect(subject.size).to eq 1
        expect(subject[0][:name]).to eq 'Name'
        expect(subject[0][:key]).to eq :name
        expect(subject[0][:value]).to eq 'Taro'
        expect(subject[0][:size]).to eq 1
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

      subject { described_class.new(definitions, options).compile }

      it 'compiles definitions' do
        expect(subject.size).to eq 1
        expect(subject[0][:name]).to eq ['Pet 1', 'Pet 2', 'Pet 3']
        expect(subject[0][:key]).to be_nil
        expect(subject[0][:value]).to be_nil
        expect(subject[0][:size]).to eq 3
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

      subject { described_class.new(definitions, options).compile }

      it 'compiles definitions' do
        expect(subject.size).to eq 1
        expect(subject[0][:name]).to be_nil
        expect(subject[0][:key]).to eq %i[pet1 pet2 pet3]
        expect(subject[0][:value]).to be_nil
        expect(subject[0][:size]).to eq 3
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

      subject { described_class.new(definitions, options).compile }

      it 'compiles definitions' do
        expect(subject.size).to eq 1
        expect(subject[0][:name]).to eq ['Pet 1', 'Pet 2', 'Pet 3']
        expect(subject[0][:key]).to eq %i[pet1 pet2]
        expect(subject[0][:value]).to be_nil
        expect(subject[0][:size]).to eq 3
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

      subject { described_class.new(definitions, options).compile }

      it 'compiles definitions' do
        expect(subject.size).to eq 1
        expect(subject[0][:name]).to eq ['Pet 1', 'Pet 2', 'Pet 3']
        expect(subject[0][:key]).to eq %i[pet1 pet2 pet3]
        expect(subject[0][:value]).to be_nil
        expect(subject[0][:size]).to eq 3
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

      subject { described_class.new(definitions, options).compile }

      it 'compiles definitions' do
        expect(subject.size).to eq 6
      end
    end
  end
end
