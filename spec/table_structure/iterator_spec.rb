# frozen_string_literal: true

RSpec.describe TableStructure::Iterator do
  let(:context) do
    {
      questions: [
        { id: 'Q1', text: 'Do you like sushi?' },
        { id: 'Q2', text: 'Do you like yakiniku?' },
        { id: 'Q3', text: 'Do you like ramen?' }
      ]
    }
  end

  let(:items) do
    [
      {
        id: 1,
        name: '太郎',
        pets: %w[cat dog],
        answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' }
      },
      {
        id: 2,
        name: '花子',
        pets: %w[rabbit turtle squirrel giraffe],
        answers: { 'Q1' => 'yes', 'Q2' => 'yes', 'Q3' => 'no' }
      },
      {
        id: 3,
        name: '次郎',
        pets: %w[tiger elephant doragon],
        answers: { 'Q1' => 'no', 'Q2' => 'yes', 'Q999' => 'yes' }
      }
    ]
  end

  let(:iterator) { described_class.new(schema_or_writer, **writer_options) }

  describe '#iterate' do
    context 'when :result_type is :array' do
      let(:schema_options) { { result_type: :array } }

      class TestTableSchema31
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
              key: question[:id].downcase.to_sym,
              value: ->(row, *) { row[:answers][question[:id]] }
            }
          end
        }

        column_converter :to_s, ->(val, *) { val.to_s }
      end

      def expect_header_as_array(row)
        expect(row.shift).to eq 'ID'
        expect(row.shift).to eq 'Name'
        expect(row.shift).to eq 'Pet 1'
        expect(row.shift).to eq 'Pet 2'
        expect(row.shift).to eq 'Pet 3'
        expect(row.shift).to eq 'Q1'
        expect(row.shift).to eq 'Q2'
        expect(row.shift).to eq 'Q3'
        expect(row.shift).to be_nil
      end

      def expect_item1_as_array(row)
        expect(row.shift).to eq '1'
        expect(row.shift).to eq '太郎'
        expect(row.shift).to eq 'cat'
        expect(row.shift).to eq 'dog'
        expect(row.shift).to eq ''
        expect(row.shift).to eq 'yes'
        expect(row.shift).to eq 'no'
        expect(row.shift).to eq 'yes'
        expect(row.shift).to be_nil
      end

      def expect_item2_as_array(row)
        expect(row.shift).to eq '2'
        expect(row.shift).to eq '花子'
        expect(row.shift).to eq 'rabbit'
        expect(row.shift).to eq 'turtle'
        expect(row.shift).to eq 'squirrel'
        expect(row.shift).to eq 'yes'
        expect(row.shift).to eq 'yes'
        expect(row.shift).to eq 'no'
        expect(row.shift).to be_nil
      end

      def expect_item3_as_array(row)
        expect(row.shift).to eq '3'
        expect(row.shift).to eq '次郎'
        expect(row.shift).to eq 'tiger'
        expect(row.shift).to eq 'elephant'
        expect(row.shift).to eq 'doragon'
        expect(row.shift).to eq 'no'
        expect(row.shift).to eq 'yes'
        expect(row.shift).to eq ''
        expect(row.shift).to be_nil
      end

      shared_examples 'to convert and iterate data' do
        context 'when :header_omitted is false' do
          let(:writer_options) { { header_omitted: false } }

          describe '#map' do
            subject { iterator.iterate(items).map(&:itself) }
            it 'returns rows as array with header' do
              expect(subject.size).to eq 4

              expect_header_as_array subject.shift
              expect_item1_as_array subject.shift
              expect_item2_as_array subject.shift
              expect_item3_as_array subject.shift
            end
          end

          describe '#take' do
            subject { iterator.iterate(items).take(1) }
            it 'returns rows as array with header' do
              expect(subject.size).to eq 1

              expect_header_as_array subject.shift
            end
          end
        end

        context 'when :header_omitted is true' do
          let(:writer_options) { { header_omitted: true } }

          describe '#map' do
            subject { iterator.iterate(items).map(&:itself) }
            it 'returns rows as array without header' do
              expect(subject.size).to eq 3

              expect_item1_as_array subject.shift
              expect_item2_as_array subject.shift
              expect_item3_as_array subject.shift
            end
          end

          describe '#take' do
            subject { iterator.iterate(items).take(1) }
            it 'returns rows as array without header' do
              expect(subject.size).to eq 1

              expect_item1_as_array subject.shift
            end
          end
        end
      end

      context 'when Schema is specified' do
        let(:schema_or_writer) { TestTableSchema31.new(context: context, **schema_options) }
        it_behaves_like 'to convert and iterate data'
      end

      context 'when Writer is specified' do
        let(:schema_or_writer) do
          schema = TestTableSchema31.new(context: context, **schema_options)
          TableStructure::Writer.new(schema, **writer_options)
        end
        it_behaves_like 'to convert and iterate data'
      end
    end

    context 'when :result_type is :hash' do
      let(:schema_options) { { result_type: :hash } }

      class TestTableSchema32
        include TableStructure::Schema

        column  name: 'ID',
                key: :id,
                value: ->(row, _table) { row[:id] }

        column  name: 'Name',
                key: :name,
                value: ->(row, *) { row[:name] }

        columns name: ['Pet 1', 'Pet 2', 'Pet 3'],
                key: %i[pet1 pet2 pet3],
                value: ->(row, *) { row[:pets] }

        columns lambda { |table|
          table[:questions].map do |question|
            {
              name: question[:id],
              key: question[:id].downcase.to_sym,
              value: ->(row, *) { row[:answers][question[:id]] }
            }
          end
        }

        column_converter :to_s, ->(val, *) { val.to_s }
      end

      def expect_header_as_hash(row)
        expect(row[:id]).to eq 'ID'
        expect(row[:name]).to eq 'Name'
        expect(row[:pet1]).to eq 'Pet 1'
        expect(row[:pet2]).to eq 'Pet 2'
        expect(row[:pet3]).to eq 'Pet 3'
        expect(row[:q1]).to eq 'Q1'
        expect(row[:q2]).to eq 'Q2'
        expect(row[:q3]).to eq 'Q3'
      end

      def expect_item1_as_hash(row)
        expect(row[:id]).to eq '1'
        expect(row[:name]).to eq '太郎'
        expect(row[:pet1]).to eq 'cat'
        expect(row[:pet2]).to eq 'dog'
        expect(row[:pet3]).to eq ''
        expect(row[:q1]).to eq 'yes'
        expect(row[:q2]).to eq 'no'
        expect(row[:q3]).to eq 'yes'
      end

      def expect_item2_as_hash(row)
        expect(row[:id]).to eq '2'
        expect(row[:name]).to eq '花子'
        expect(row[:pet1]).to eq 'rabbit'
        expect(row[:pet2]).to eq 'turtle'
        expect(row[:pet3]).to eq 'squirrel'
        expect(row[:q1]).to eq 'yes'
        expect(row[:q2]).to eq 'yes'
        expect(row[:q3]).to eq 'no'
      end

      def expect_item3_as_hash(row)
        expect(row[:id]).to eq '3'
        expect(row[:name]).to eq '次郎'
        expect(row[:pet1]).to eq 'tiger'
        expect(row[:pet2]).to eq 'elephant'
        expect(row[:pet3]).to eq 'doragon'
        expect(row[:q1]).to eq 'no'
        expect(row[:q2]).to eq 'yes'
        expect(row[:q3]).to eq ''
      end

      shared_examples 'to convert and iterate data' do
        context 'when :header_omitted is false' do
          let(:writer_options) { { header_omitted: false } }

          describe '#map' do
            subject { iterator.iterate(items).map(&:itself) }
            it 'returns rows as hash with header' do
              expect(subject.size).to eq 4

              expect_header_as_hash subject.shift
              expect_item1_as_hash subject.shift
              expect_item2_as_hash subject.shift
              expect_item3_as_hash subject.shift
            end
          end

          describe '#take' do
            subject { iterator.iterate(items).take(1) }
            it 'returns rows as hash with header' do
              expect(subject.size).to eq 1

              expect_header_as_hash subject.shift
            end
          end
        end

        context 'when :header_omitted is true' do
          let(:writer_options) { { header_omitted: true } }

          describe '#map' do
            subject { iterator.iterate(items).map(&:itself) }
            it 'returns rows as hash without header' do
              expect(subject.size).to eq 3

              expect_item1_as_hash subject.shift
              expect_item2_as_hash subject.shift
              expect_item3_as_hash subject.shift
            end
          end

          describe '#take' do
            subject { iterator.iterate(items).take(1) }
            it 'returns rows as hash without header' do
              expect(subject.size).to eq 1

              expect_item1_as_hash subject.shift
            end
          end
        end
      end

      context 'when Schema is specified' do
        let(:schema_or_writer) { TestTableSchema32.new(context: context, **schema_options) }
        it_behaves_like 'to convert and iterate data'
      end

      context 'when Writer is specified' do
        let(:schema_or_writer) do
          schema = TestTableSchema32.new(context: context, **schema_options)
          TableStructure::Writer.new(schema, **writer_options)
        end
        it_behaves_like 'to convert and iterate data'
      end
    end
  end
end
