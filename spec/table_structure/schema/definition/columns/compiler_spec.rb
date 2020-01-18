# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Definition::Columns::Compiler do
  let(:schema_name) { 'TestTableSchema' }
  let(:options) { {} }

  describe '#compile' do
    context 'when definition is empty' do
      let(:definitions) do
        [
          {}
        ]
      end

      subject { described_class.new(schema_name, definitions, options).compile }

      it 'compiles definitions' do
        expect(::TableStructure::Schema::Columns::Attributes)
          .to receive(:new).with(**{
                                   name: nil,
                                   key: nil,
                                   value: nil,
                                   size: 1
                                 }).and_call_original

        expect(subject.size).to eq 1
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

      subject { described_class.new(schema_name, definitions, options).compile }

      it 'compiles definitions' do
        expect(::TableStructure::Schema::Columns::Attributes)
          .to receive(:new).with(**{
                                   name: 'Name',
                                   key: :name,
                                   value: 'Taro',
                                   size: 1
                                 }).and_call_original

        expect(subject.size).to eq 1
      end
    end

    context 'when size is callable' do
      let(:definitions) do
        [
          {
            name: 'Name',
            key: %i[first_name last_name],
            value: %w[Taro Momo],
            size: ->(table) { table[:size] }
          }
        ]
      end

      let(:context) { { size: 2 } }

      subject { described_class.new(schema_name, definitions, options).compile(context) }

      it 'compiles definitions' do
        expect(::TableStructure::Schema::Columns::Attributes)
          .to receive(:new).with(**{
                                   name: 'Name',
                                   key: %i[first_name last_name],
                                   value: %w[Taro Momo],
                                   size: 2
                                 }).and_call_original

        expect(subject.size).to eq 1
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

        subject { described_class.new(schema_name, definitions, options).compile }

        it 'compiles definitions' do
          expect(::TableStructure::Schema::Columns::Attributes)
            .to receive(:new).with(**{
                                     name: ['Pet 1', 'Pet 2', 'Pet 3'],
                                     key: nil,
                                     value: nil,
                                     size: 3
                                   }).and_call_original

          expect(subject.size).to eq 1
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

        subject { described_class.new(schema_name, definitions, options).compile }

        it 'compiles definitions' do
          expect(::TableStructure::Schema::Columns::Attributes)
            .to receive(:new).with(**{
                                     name: nil,
                                     key: %i[pet1 pet2 pet3],
                                     value: nil,
                                     size: 3
                                   }).and_call_original

          expect(subject.size).to eq 1
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

          subject { described_class.new(schema_name, definitions, options).compile }

          it 'compiles definitions' do
            expect(::TableStructure::Schema::Columns::Attributes)
              .to receive(:new).with(**{
                                       name: ['Pet 1', 'Pet 2', 'Pet 3'],
                                       key: %i[pet1 pet2],
                                       value: nil,
                                       size: 3
                                     }).and_call_original

            expect(subject.size).to eq 1
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

          subject { described_class.new(schema_name, definitions, options).compile }

          it 'compiles definitions' do
            expect(::TableStructure::Schema::Columns::Attributes)
              .to receive(:new).with(**{
                                       name: ['Pet 1', 'Pet 2'],
                                       key: %i[pet1 pet2 pet3],
                                       value: nil,
                                       size: 3
                                     }).and_call_original

            expect(subject.size).to eq 1
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

          subject { described_class.new(schema_name, definitions, options).compile }

          it 'compiles definitions' do
            expect(::TableStructure::Schema::Columns::Attributes)
              .to receive(:new).with(**{
                                       name: ['Pet 1', 'Pet 2', 'Pet 3'],
                                       key: %i[pet1 pet2 pet3],
                                       value: nil,
                                       size: 3
                                     }).and_call_original

            expect(subject.size).to eq 1
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

      subject { described_class.new(schema_name, definitions, options).compile }

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
        subject { described_class.new(schema_name, definitions, options).compile }

        context 'as true' do
          let(:omitted) { true }

          it 'compiles definitions' do
            expect(::TableStructure::Schema::Columns::Attributes)
              .to receive(:new).with(**{
                                       name: 'Name',
                                       key: nil,
                                       value: 'Taro',
                                       size: 1
                                     }).and_call_original

            expect(subject.size).to eq 1
          end
        end

        context 'as false' do
          let(:omitted) { false }

          before do
            expect(::TableStructure::Schema::Columns::Attributes)
              .to receive(:new).with(**attributes1).and_call_original
            expect(::TableStructure::Schema::Columns::Attributes)
              .to receive(:new).with(**attributes2).and_call_original
          end

          let(:attributes1) do
            {
              name: 'ID',
              key: nil,
              value: 1,
              size: 1
            }
          end

          let(:attributes2) do
            {
              name: 'Name',
              key: nil,
              value: 'Taro',
              size: 1
            }
          end

          it 'compiles definitions' do
            expect(subject.size).to eq 2
          end
        end
      end

      context 'by lambda' do
        subject { described_class.new(schema_name, definitions, options).compile(context) }

        context 'as true' do
          let(:omitted) { ->(table) { !table[:admin] } }
          let(:context) { { admin: false } }

          it 'compiles definitions' do
            expect(::TableStructure::Schema::Columns::Attributes)
              .to receive(:new).with(**{
                                       name: 'Name',
                                       key: nil,
                                       value: 'Taro',
                                       size: 1
                                     }).and_call_original

            expect(subject.size).to eq 1
          end
        end

        context 'as false' do
          let(:omitted) { ->(table) { !table[:admin] } }
          let(:context) { { admin: true } }

          it 'compiles definitions' do
            expect(::TableStructure::Schema::Columns::Attributes)
              .to receive(:new).with(**{
                                       name: 'ID',
                                       key: nil,
                                       value: 1,
                                       size: 1
                                     }).and_call_original

            expect(::TableStructure::Schema::Columns::Attributes)
              .to receive(:new).with(**{
                                       name: 'Name',
                                       key: nil,
                                       value: 'Taro',
                                       size: 1
                                     }).and_call_original

            expect(subject.size).to eq 2
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

      subject { described_class.new(schema_name, definitions, options).compile(context) }

      context 'that is class' do
        let(:definitions) { [TestTableSchema1] }

        before do
          expect(::TableStructure::Schema::Columns::Schema)
            .to receive(:new).with(definitions[0]).and_call_original
        end

        it 'compiles definitions' do
          expect(subject.size).to eq 1
        end
      end

      context 'that is instance' do
        let(:definitions) { [TestTableSchema1.new(context: context)] }

        before do
          expect(::TableStructure::Schema::Columns::Schema)
            .to receive(:new).with(definitions[0]).and_call_original
        end

        it 'compiles definitions' do
          expect(subject.size).to eq 1
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

      subject { described_class.new(schema_name, definitions, options).compile }

      context 'and `:nil_definitions_ignored` option is set `true`' do
        let(:options) { { nil_definitions_ignored: true } }

        it 'compiles definitions' do
          expect(::TableStructure::Schema::Columns::Attributes)
            .to receive(:new).with(**{
                                     name: 'a',
                                     key: nil,
                                     value: nil,
                                     size: 1
                                   }).and_call_original

          expect(::TableStructure::Schema::Columns::Attributes)
            .to receive(:new).with(**{
                                     name: 'b',
                                     key: nil,
                                     value: nil,
                                     size: 1
                                   }).and_call_original

          expect(subject.size).to eq 2
        end
      end

      context 'and `:nil_definitions_ignored` option is set `false`' do
        let(:options) { { nil_definitions_ignored: false } }

        it { expect { subject }.to raise_error TableStructure::Schema::Definition::Columns::Error }
      end
    end

    context 'when definitions are empty' do
      let(:definitions) do
        [
          []
        ]
      end

      subject { described_class.new(schema_name, definitions, options).compile }

      it 'compiles definitions' do
        expect(subject.size).to eq 0
      end
    end
  end
end
