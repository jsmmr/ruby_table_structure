# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Definition::Compiler do
  let(:name) { 'TestTableSchema' }
  let(:options) { {} }

  describe '#compile' do
    context 'when definition is empty' do
      let(:definitions) do
        [
          {}
        ]
      end

      subject { described_class.new(name, definitions, options).compile }

      it 'compiles definitions' do
        expect(subject.size).to eq 1
        expect(subject[0][:name]).to be_nil
        expect(subject[0][:key]).to be_nil
        expect(subject[0][:value]).to be_nil
        expect(subject[0][:size]).to eq 1
      end
    end

    context 'when definition is complete' do
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

      subject { described_class.new(name, definitions, options).compile }

      it 'compiles definitions' do
        expect(subject.size).to eq 1
        expect(subject[0][:name]).to eq 'Name'
        expect(subject[0][:key]).to eq :name
        expect(subject[0][:value]).to eq 'Taro'
        expect(subject[0][:size]).to eq 1
      end
    end

    context 'when size is determined automatically' do
      context 'when only name is specified' do
        let(:definitions) do
          [
            {
              name: ['Pet 1', 'Pet 2', 'Pet 3']
            }
          ]
        end

        subject { described_class.new(name, definitions, options).compile }

        it 'compiles definitions' do
          expect(subject.size).to eq 1
          expect(subject[0][:name]).to eq ['Pet 1', 'Pet 2', 'Pet 3']
          expect(subject[0][:key]).to be_nil
          expect(subject[0][:value]).to be_nil
          expect(subject[0][:size]).to eq 3
        end
      end

      context 'when only key is specified' do
        let(:definitions) do
          [
            {
              key: %i[pet1 pet2 pet3]
            }
          ]
        end

        subject { described_class.new(name, definitions, options).compile }

        it 'compiles definitions' do
          expect(subject.size).to eq 1
          expect(subject[0][:name]).to be_nil
          expect(subject[0][:key]).to eq %i[pet1 pet2 pet3]
          expect(subject[0][:value]).to be_nil
          expect(subject[0][:size]).to eq 3
        end
      end

      context 'when both name and key are specified' do
        context 'when name size is larger' do
          let(:definitions) do
            [
              {
                name: ['Pet 1', 'Pet 2', 'Pet 3'],
                key: %i[pet1 pet2]
              }
            ]
          end

          subject { described_class.new(name, definitions, options).compile }

          it 'compiles definitions' do
            expect(subject.size).to eq 1
            expect(subject[0][:name]).to eq ['Pet 1', 'Pet 2', 'Pet 3']
            expect(subject[0][:key]).to eq %i[pet1 pet2]
            expect(subject[0][:value]).to be_nil
            expect(subject[0][:size]).to eq 3
          end
        end

        context 'when key size is larger' do
          let(:definitions) do
            [
              {
                name: ['Pet 1', 'Pet 2'],
                key: %i[pet1 pet2 pet3]
              }
            ]
          end

          subject { described_class.new(name, definitions, options).compile }

          it 'compiles definitions' do
            expect(subject.size).to eq 1
            expect(subject[0][:name]).to eq ['Pet 1', 'Pet 2']
            expect(subject[0][:key]).to eq %i[pet1 pet2 pet3]
            expect(subject[0][:value]).to be_nil
            expect(subject[0][:size]).to eq 3
          end
        end

        context 'when both sizes are same' do
          let(:definitions) do
            [
              {
                name: ['Pet 1', 'Pet 2', 'Pet 3'],
                key: %i[pet1 pet2 pet3]
              }
            ]
          end

          subject { described_class.new(name, definitions, options).compile }

          it 'compiles definitions' do
            expect(subject.size).to eq 1
            expect(subject[0][:name]).to eq ['Pet 1', 'Pet 2', 'Pet 3']
            expect(subject[0][:key]).to eq %i[pet1 pet2 pet3]
            expect(subject[0][:value]).to be_nil
            expect(subject[0][:size]).to eq 3
          end
        end
      end
    end

    context 'when multiple definitions are contained' do
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

      subject { described_class.new(name, definitions, options).compile }

      it 'compiles definitions' do
        expect(subject.size).to eq 6
      end
    end

    context 'when "omitted" is specified' do
      let(:definitions) do
        [
          {
            name: 'ID',
            value: 1,
            omitted: omitted
          },
          {
            name: 'Name',
            value: 'Taro'
          }
        ]
      end

      context 'by other than lambda' do
        subject { described_class.new(name, definitions, options).compile }

        context 'as true' do
          let(:omitted) { true }

          it 'compiles definitions' do
            expect(subject.size).to eq 1
            expect(subject[0][:name]).to eq 'Name'
            expect(subject[0][:key]).to be_nil
            expect(subject[0][:value]).to eq 'Taro'
            expect(subject[0][:size]).to eq 1
          end
        end

        context 'as false' do
          let(:omitted) { false }

          it 'compiles definitions' do
            expect(subject.size).to eq 2
            expect(subject[0][:name]).to eq 'ID'
            expect(subject[0][:key]).to be_nil
            expect(subject[0][:value]).to eq 1
            expect(subject[0][:size]).to eq 1
          end
        end
      end

      context 'by lambda' do
        subject { described_class.new(name, definitions, options).compile(context) }

        context 'as true' do
          let(:omitted) { ->(table) { !table[:admin] } }
          let(:context) { { admin: false } }

          it 'compiles definitions' do
            expect(subject.size).to eq 1
            expect(subject[0][:name]).to eq 'Name'
            expect(subject[0][:key]).to be_nil
            expect(subject[0][:value]).to eq 'Taro'
            expect(subject[0][:size]).to eq 1
          end
        end

        context 'as false' do
          let(:omitted) { ->(table) { !table[:admin] } }
          let(:context) { { admin: true } }

          it 'compiles definitions' do
            expect(subject.size).to eq 2
            expect(subject[0][:name]).to eq 'ID'
            expect(subject[0][:key]).to be_nil
            expect(subject[0][:value]).to eq 1
            expect(subject[0][:size]).to eq 1
          end
        end
      end
    end

    context 'when schema is nested' do
      class TestTableSchema1
        include TableStructure::Schema

        column  name: 'ID',
                value: ->(row, _table) { row[:id] }

        column  name: 'Name',
                value: ->(row, *) { row[:name] }

        columns name: ['Pet 1', 'Pet 2', 'Pet 3'],
                value: ->(row, *) { row[:pets] }

        columns lambda { |table|
          table[:questions].map do |question|
            {
              name: question[:id],
              value: ->(row, *) { row[:answers][question[:id]] }
            }
          end
        }
      end

      let(:context) do
        {
          questions: [
            { id: 'Q1', text: 'Do you like sushi?' },
            { id: 'Q2', text: 'Do you like yakiniku?' },
            { id: 'Q3', text: 'Do you like ramen?' }
          ]
        }
      end

      subject { described_class.new(name, definitions, options).compile(context) }

      context 'that is class' do
        let(:definitions) { [TestTableSchema1] }

        it 'compiles definitions' do
          expect(subject.size).to eq 1
          expect(subject[0]).to be_a TestTableSchema1
        end
      end

      context 'that is instance' do
        let(:definitions) { [TestTableSchema1.new(context: context)] }

        it 'compiles definitions' do
          expect(subject[0]).to be_a TestTableSchema1
        end
      end
    end

    context 'when definitions contain nil' do
      let(:definitions) do
        [
          nil,
          { name: 'a' },
          [nil, nil],
          [nil, { name: 'b' }, nil]
        ]
      end

      subject { described_class.new(name, definitions, options).compile }

      context 'and `:nil_definitions_ignored` option is set `true`' do
        let(:options) { { nil_definitions_ignored: true } }

        it 'compiles definitions' do
          expect(subject.size).to eq 2
          expect(subject[0][:name]).to eq 'a'
          expect(subject[1][:name]).to eq 'b'
        end
      end

      context 'and `:nil_definitions_ignored` option is set `false`' do
        let(:options) { { nil_definitions_ignored: false } }

        it { expect { subject }.to raise_error TableStructure::Schema::Definition::Error }
      end
    end

    context 'when definitions are empty' do
      let(:definitions) do
        [
          []
        ]
      end

      subject { described_class.new(name, definitions, options).compile }

      it 'compiles definitions' do
        expect(subject.size).to eq 0
      end
    end
  end
end
