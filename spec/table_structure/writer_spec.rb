# frozen_string_literal: true

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

      columns lambda { |table|
        table[:questions].map do |question|
          {
            name: question[:id],
            value: ->(row, *) { row[:answers][question[:id]] }
          }
        end
      }

      column_converter :to_s, ->(val, _row, _table) { val.to_s }
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

    let(:array_items) do
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

    let(:lambda_items) do
      ->(y) { array_items.each { |item| y << item } }
    end

    let(:enumerator_items) do
      Enumerator.new { |y| array_items.each { |item| y << item } }
    end

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

        context 'when passed enumerator_items' do
          let(:items) { enumerator_items }
          it_behaves_like 'to convert and write data'
        end
      end

      context 'when CSV encoding is Shift_JIS' do
        let(:csv_options) { { encoding: 'Shift_JIS:UTF-8' } }
        let(:converter) do
          lambda do |values|
            values.map { |val| val&.to_s&.encode('Shift_JIS', invalid: :replace, undef: :replace) }
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

        context 'when passed enumerator_items' do
          let(:items) { enumerator_items }
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

      context 'when passed enumerator_items' do
        let(:items) { enumerator_items }
        it_behaves_like 'to convert and write data'
      end
    end

    context 'when output to array' do
      context 'with result_type: :array' do
        let(:options) { { result_type: :array } }

        shared_examples 'to convert and write data' do
          it 'succeeds' do
            table = []
            writer.write(items, to: table)

            expect(table[0]).to be_a Array

            expect(table[0].shift).to eq 'ID'
            expect(table[0].shift).to eq 'Name'
            expect(table[0].shift).to eq 'Pet 1'
            expect(table[0].shift).to eq 'Pet 2'
            expect(table[0].shift).to eq 'Pet 3'
            expect(table[0].shift).to eq 'Q1'
            expect(table[0].shift).to eq 'Q2'
            expect(table[0].shift).to eq 'Q3'
            expect(table[0].shift).to be_nil

            expect(table[1]).to be_a Array

            expect(table[1].shift).to eq '1'
            expect(table[1].shift).to eq '太郎'
            expect(table[1].shift).to eq 'cat'
            expect(table[1].shift).to eq 'dog'
            expect(table[1].shift).to eq ''
            expect(table[1].shift).to eq 'yes'
            expect(table[1].shift).to eq 'no'
            expect(table[1].shift).to eq 'yes'
            expect(table[1].shift).to be_nil

            expect(table[2]).to be_a Array

            expect(table[2].shift).to eq '2'
            expect(table[2].shift).to eq '花子'
            expect(table[2].shift).to eq 'rabbit'
            expect(table[2].shift).to eq 'turtle'
            expect(table[2].shift).to eq 'squirrel'
            expect(table[2].shift).to eq 'yes'
            expect(table[2].shift).to eq 'yes'
            expect(table[2].shift).to eq 'no'
            expect(table[2].shift).to be_nil

            expect(table[3]).to be_a Array

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

        context 'deprecated' do
          let(:schema) { TestTableSchema21.new(context: context, **options) }
          let(:writer) { TableStructure::Writer.new(schema) }

          context 'when passed array_items' do
            let(:items) { array_items }
            it_behaves_like 'to convert and write data'
          end

          context 'when passed lambda_items' do
            let(:items) { lambda_items }
            it_behaves_like 'to convert and write data'
          end

          context 'when passed enumerator_items' do
            let(:items) { enumerator_items }
            it_behaves_like 'to convert and write data'
          end
        end

        context 'recommend' do
          let(:schema) { TestTableSchema21.new(context: context) }
          let(:writer) { TableStructure::Writer.new(schema, options) }

          context 'when passed array_items' do
            let(:items) { array_items }
            it_behaves_like 'to convert and write data'
          end

          context 'when passed lambda_items' do
            let(:items) { lambda_items }
            it_behaves_like 'to convert and write data'
          end

          context 'when passed enumerator_items' do
            let(:items) { enumerator_items }
            it_behaves_like 'to convert and write data'
          end
        end
      end

      context 'with result_type: :hash' do
        let(:options) { { result_type: :hash } }

        shared_examples 'to convert and write data' do
          it 'succeeds' do
            table = []
            writer.write(items, to: table)

            expect(table[0]).to be_a Hash

            expect(table[0].fetch(0)).to eq 'ID'
            expect(table[0].fetch(1)).to eq 'Name'
            expect(table[0].fetch(2)).to eq 'Pet 1'
            expect(table[0].fetch(3)).to eq 'Pet 2'
            expect(table[0].fetch(4)).to eq 'Pet 3'
            expect(table[0].fetch(5)).to eq 'Q1'
            expect(table[0].fetch(6)).to eq 'Q2'
            expect(table[0].fetch(7)).to eq 'Q3'

            expect(table[1]).to be_a Hash

            expect(table[1].fetch(0)).to eq '1'
            expect(table[1].fetch(1)).to eq '太郎'
            expect(table[1].fetch(2)).to eq 'cat'
            expect(table[1].fetch(3)).to eq 'dog'
            expect(table[1].fetch(4)).to eq ''
            expect(table[1].fetch(5)).to eq 'yes'
            expect(table[1].fetch(6)).to eq 'no'
            expect(table[1].fetch(7)).to eq 'yes'

            expect(table[2]).to be_a Hash

            expect(table[2].fetch(0)).to eq '2'
            expect(table[2].fetch(1)).to eq '花子'
            expect(table[2].fetch(2)).to eq 'rabbit'
            expect(table[2].fetch(3)).to eq 'turtle'
            expect(table[2].fetch(4)).to eq 'squirrel'
            expect(table[2].fetch(5)).to eq 'yes'
            expect(table[2].fetch(6)).to eq 'yes'
            expect(table[2].fetch(7)).to eq 'no'

            expect(table[3]).to be_a Hash

            expect(table[3].fetch(0)).to eq '3'
            expect(table[3].fetch(1)).to eq '次郎'
            expect(table[3].fetch(2)).to eq 'tiger'
            expect(table[3].fetch(3)).to eq 'elephant'
            expect(table[3].fetch(4)).to eq 'doragon'
            expect(table[3].fetch(5)).to eq 'no'
            expect(table[3].fetch(6)).to eq 'yes'
            expect(table[3].fetch(7)).to eq ''
          end
        end

        context 'deprecated' do
          let(:schema) { TestTableSchema21.new(context: context, **options) }
          let(:writer) { TableStructure::Writer.new(schema) }

          context 'when passed array_items' do
            let(:items) { array_items }
            it_behaves_like 'to convert and write data'
          end

          context 'when passed lambda_items' do
            let(:items) { lambda_items }
            it_behaves_like 'to convert and write data'
          end

          context 'when passed enumerator_items' do
            let(:items) { enumerator_items }
            it_behaves_like 'to convert and write data'
          end
        end

        context 'recommend' do
          let(:schema) { TestTableSchema21.new(context: context) }
          let(:writer) { TableStructure::Writer.new(schema, options) }

          context 'when passed array_items' do
            let(:items) { array_items }
            it_behaves_like 'to convert and write data'
          end

          context 'when passed lambda_items' do
            let(:items) { lambda_items }
            it_behaves_like 'to convert and write data'
          end

          context 'when passed enumerator_items' do
            let(:items) { enumerator_items }
            it_behaves_like 'to convert and write data'
          end
        end
      end
    end

    context 'when output to string' do
      shared_examples 'to convert and write data' do
        it 'succeeds' do
          require 'csv'

          schema = TestTableSchema21.new(context: context)
          writer = TableStructure::Writer.new(schema)
          s = String.new
          writer.write(items, to: s) do |row_values|
            row_values.join(',') + "\n"
          end

          expect(s).to eq "ID,Name,Pet 1,Pet 2,Pet 3,Q1,Q2,Q3\n" \
                          "1,太郎,cat,dog,,yes,no,yes\n" \
                          "2,花子,rabbit,turtle,squirrel,yes,yes,no\n" \
                          "3,次郎,tiger,elephant,doragon,no,yes,\n"
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

      context 'when passed enumerator_items' do
        let(:items) { enumerator_items }
        it_behaves_like 'to convert and write data'
      end
    end
  end
end
