RSpec.describe TableStructure::Writer do

  describe '#write' do
    class TestTableSchema21
      include TableStructure::Schema

      column  name: 'ID',
              value: ->(row, _table) { row[:id] }

      column  name: 'Name',
              value: ->(row, *) { row[:name] }

      columns name: ['Pet 1', 'Pet 2', 'Pet 3'],
              value: ->(row, *) { row[:pets] }

      columns ->(table) {
        table[:questions].map do |question|
          {
            name: question[:id],
            value: ->(row, *) { row[:answers][question[:id]] }
          }
        end
      }

      column_converter :to_s, ->(val, _row, _table) { val.to_s }
    end

    let(:context) {
      {
        questions: [
          { id: 'Q1', text: 'Do you like sushi?' },
          { id: 'Q2', text: 'Do you like yakiniku?' },
          { id: 'Q3', text: 'Do you like ramen?' },
        ]
      }
    }

    let(:array_items) {
      [
        {
          id: 1,
          name: '太郎',
          pets: ['cat', 'dog'],
          answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' }
        },
        {
          id: 2,
          name: '花子',
          pets: ['rabbit', 'turtle', 'squirrel', 'giraffe'],
          answers: { 'Q1' => 'yes', 'Q2' => 'yes', 'Q3' => 'no' }
        },
        {
          id: 3,
          name: '次郎',
          pets: ['tiger', 'elephant', 'doragon'],
          answers: { 'Q1' => 'no', 'Q2' => 'yes', 'Q999' => 'yes' }
        }
      ]
    }

    let(:lambda_items) {
      ->(y) { array_items.each { |item| y << item } }
    }

    context 'when output to CSV file' do
      shared_examples 'to convert and write data' do
        it 'succeeds' do
          require 'csv'
          require 'tempfile'

          schema = TestTableSchema21.new(context: context)
          writer = TableStructure::Writer.new(schema)

          tf = Tempfile.open do |fp|
            writer.write(items, to: CSV.new(fp), &converter)
            fp
          end

          table = CSV.read(tf.path, **csv_options)

          expect(table[0].shift).to eq 'ID'
          expect(table[0].shift).to eq 'Name'
          expect(table[0].shift).to eq 'Pet 1'
          expect(table[0].shift).to eq 'Pet 2'
          expect(table[0].shift).to eq 'Pet 3'
          expect(table[0].shift).to eq 'Q1'
          expect(table[0].shift).to eq 'Q2'
          expect(table[0].shift).to eq 'Q3'
          expect(table[0].shift).to be_nil

          expect(table[1].shift).to eq '1'
          expect(table[1].shift).to eq '太郎'
          expect(table[1].shift).to eq 'cat'
          expect(table[1].shift).to eq 'dog'
          expect(table[1].shift).to eq ''
          expect(table[1].shift).to eq 'yes'
          expect(table[1].shift).to eq 'no'
          expect(table[1].shift).to eq 'yes'
          expect(table[1].shift).to be_nil

          expect(table[2].shift).to eq '2'
          expect(table[2].shift).to eq '花子'
          expect(table[2].shift).to eq 'rabbit'
          expect(table[2].shift).to eq 'turtle'
          expect(table[2].shift).to eq 'squirrel'
          expect(table[2].shift).to eq 'yes'
          expect(table[2].shift).to eq 'yes'
          expect(table[2].shift).to eq 'no'
          expect(table[2].shift).to be_nil

          expect(table[3].shift).to eq '3'
          expect(table[3].shift).to eq '次郎'
          expect(table[3].shift).to eq 'tiger'
          expect(table[3].shift).to eq 'elephant'
          expect(table[3].shift).to eq 'doragon'
          expect(table[3].shift).to eq 'no'
          expect(table[3].shift).to eq 'yes'
          expect(table[3].shift).to eq ''
          expect(table[3].shift).to be_nil
        end
      end

      context 'when CSV encoding is UTF-8' do
        let(:csv_options) { {} }
        let(:converter) { ->(values) { values } }

        context 'when passed array_items' do
          let(:items) { array_items }
          it_behaves_like 'to convert and write data'
        end

        context 'when passed lambda_items' do
          let(:items) { lambda_items }
          it_behaves_like 'to convert and write data'
        end
      end

      context 'when CSV encoding is Shift_JIS' do
        let(:csv_options) { { encoding: 'Shift_JIS:UTF-8' } }
        let(:converter) {
          ->(values) {
            values.map { |val| val&.to_s&.encode('Shift_JIS', invalid: :replace, undef: :replace) }
          }
        }

        context 'when passed array_items' do
          let(:items) { array_items }
          it_behaves_like 'to convert and write data'
        end

        context 'when passed lambda_items' do
          let(:items) { lambda_items }
          it_behaves_like 'to convert and write data'
        end
      end
    end

    context 'when output to yielder' do
      shared_examples 'to convert and write data' do
        it 'succeeds' do
          schema = TestTableSchema21.new(context: context)
          writer = TableStructure::Writer.new(schema)
          enum = Enumerator.new { |y| writer.write(items, to: y) }

          row = enum.next
          expect(row.shift).to eq 'ID'
          expect(row.shift).to eq 'Name'
          expect(row.shift).to eq 'Pet 1'
          expect(row.shift).to eq 'Pet 2'
          expect(row.shift).to eq 'Pet 3'
          expect(row.shift).to eq 'Q1'
          expect(row.shift).to eq 'Q2'
          expect(row.shift).to eq 'Q3'
          expect(row.shift).to be_nil

          row = enum.next
          expect(row.shift).to eq '1'
          expect(row.shift).to eq '太郎'
          expect(row.shift).to eq 'cat'
          expect(row.shift).to eq 'dog'
          expect(row.shift).to eq ''
          expect(row.shift).to eq 'yes'
          expect(row.shift).to eq 'no'
          expect(row.shift).to eq 'yes'
          expect(row.shift).to be_nil

          row = enum.next
          expect(row.shift).to eq '2'
          expect(row.shift).to eq '花子'
          expect(row.shift).to eq 'rabbit'
          expect(row.shift).to eq 'turtle'
          expect(row.shift).to eq 'squirrel'
          expect(row.shift).to eq 'yes'
          expect(row.shift).to eq 'yes'
          expect(row.shift).to eq 'no'
          expect(row.shift).to be_nil

          row = enum.next
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
      end

      context 'when passed array_items' do
        let(:items) { array_items }
        it_behaves_like 'to convert and write data'
      end

      context 'when passed lambda_items' do
        let(:items) { lambda_items }
        it_behaves_like 'to convert and write data'
      end
    end

    context 'when output to array' do
      shared_examples 'to convert and write data' do
        it 'succeeds' do
          schema = TestTableSchema21.new(context: context)
          writer = TableStructure::Writer.new(schema)
          table = []
          writer.write(items, to: table)

          expect(table[0].shift).to eq 'ID'
          expect(table[0].shift).to eq 'Name'
          expect(table[0].shift).to eq 'Pet 1'
          expect(table[0].shift).to eq 'Pet 2'
          expect(table[0].shift).to eq 'Pet 3'
          expect(table[0].shift).to eq 'Q1'
          expect(table[0].shift).to eq 'Q2'
          expect(table[0].shift).to eq 'Q3'
          expect(table[0].shift).to be_nil

          expect(table[1].shift).to eq '1'
          expect(table[1].shift).to eq '太郎'
          expect(table[1].shift).to eq 'cat'
          expect(table[1].shift).to eq 'dog'
          expect(table[1].shift).to eq ''
          expect(table[1].shift).to eq 'yes'
          expect(table[1].shift).to eq 'no'
          expect(table[1].shift).to eq 'yes'
          expect(table[1].shift).to be_nil

          expect(table[2].shift).to eq '2'
          expect(table[2].shift).to eq '花子'
          expect(table[2].shift).to eq 'rabbit'
          expect(table[2].shift).to eq 'turtle'
          expect(table[2].shift).to eq 'squirrel'
          expect(table[2].shift).to eq 'yes'
          expect(table[2].shift).to eq 'yes'
          expect(table[2].shift).to eq 'no'
          expect(table[2].shift).to be_nil

          expect(table[3].shift).to eq '3'
          expect(table[3].shift).to eq '次郎'
          expect(table[3].shift).to eq 'tiger'
          expect(table[3].shift).to eq 'elephant'
          expect(table[3].shift).to eq 'doragon'
          expect(table[3].shift).to eq 'no'
          expect(table[3].shift).to eq 'yes'
          expect(table[3].shift).to eq ''
          expect(table[3].shift).to be_nil
        end
      end

      context 'when passed array_items' do
        let(:items) { array_items }
        it_behaves_like 'to convert and write data'
      end

      context 'when passed lambda_items' do
        let(:items) { lambda_items }
        it_behaves_like 'to convert and write data'
      end
    end
  end

end