# frozen_string_literal: true

RSpec.describe TableStructure::Writer do
  describe '#write' do
    include_context 'questions'
    include_context 'users'

    let(:context) { { questions: questions } }

    let(:array_items) { users }

    let(:lambda_items) do
      ->(y) { array_items.each { |item| y << item } }
    end

    let(:enumerator_items) do
      ::Enumerator.new { |y| array_items.each { |item| y << item } }
    end

    context 'when output to CSV file' do
      shared_examples 'to convert and write data' do
        it 'succeeds' do
          require 'csv'
          require 'tempfile'

          schema = ::Mono::TestTableSchema.new(context: context) do
            column_converter :to_s, ->(val, *) { val.to_s }
          end
          writer = described_class.new(schema)

          tf = ::Tempfile.open do |fp|
            writer.write(items, to: ::CSV.new(fp), &converter)
            fp
          end

          table = ::CSV.read(tf.path, **csv_options)

          expect(table[0]).to eq [
            'ID',
            'Name',
            'Pet 1',
            'Pet 2',
            'Pet 3',
            'Q1',
            'Q2',
            'Q3'
          ]

          expect(table[1]).to eq [
            '1',
            '太郎',
            'cat',
            'dog',
            '',
            'yes',
            'no',
            'yes'
          ]

          expect(table[2]).to eq %w[
            2
            花子
            rabbit
            turtle
            squirrel
            yes
            yes
            no
          ]

          expect(table[3]).to eq [
            '3',
            '次郎',
            'tiger',
            'elephant',
            'doragon',
            'no',
            'yes',
            ''
          ]
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
            values.map { |val| val.encode('Shift_JIS', invalid: :replace, undef: :replace) }
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
          schema = ::Mono::TestTableSchema.new(context: context)
          writer = described_class.new(schema)
          times = 0
          enum = ::Enumerator.new do |y|
            writer.write(items, to: y) do |values|
              times += 1
              values
            end
          end

          expect(enum.next).to eq [
            'ID',
            'Name',
            'Pet 1',
            'Pet 2',
            'Pet 3',
            'Q1',
            'Q2',
            'Q3'
          ]
          expect(times).to eq 1

          expect(enum.next).to eq [
            1,
            '太郎',
            'cat',
            'dog',
            nil,
            'yes',
            'no',
            'yes'
          ]
          expect(times).to eq 2

          expect(enum.next).to eq [
            2,
            '花子',
            'rabbit',
            'turtle',
            'squirrel',
            'yes',
            'yes',
            'no'
          ]
          expect(times).to eq 3

          expect(enum.next).to eq [
            3,
            '次郎',
            'tiger',
            'elephant',
            'doragon',
            'no',
            'yes',
            nil
          ]
          expect(times).to eq 4
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
        let(:options) do
          [
            { result_type: :array }, # deprecated
            { row_type: :array }
          ].sample
        end

        shared_examples 'to convert and write data' do
          it 'succeeds' do
            table = []
            writer.write(items, to: table)

            expect(table[0]).to eq [
              'ID',
              'Name',
              'Pet 1',
              'Pet 2',
              'Pet 3',
              'Q1',
              'Q2',
              'Q3'
            ]

            expect(table[1]).to eq [
              1,
              '太郎',
              'cat',
              'dog',
              nil,
              'yes',
              'no',
              'yes'
            ]

            expect(table[2]).to eq [
              2,
              '花子',
              'rabbit',
              'turtle',
              'squirrel',
              'yes',
              'yes',
              'no'
            ]

            expect(table[3]).to eq [
              3,
              '次郎',
              'tiger',
              'elephant',
              'doragon',
              'no',
              'yes',
              nil
            ]
          end
        end

        context 'deprecated' do
          let(:schema) { ::Mono::TestTableSchema.new(context: context, **options) }
          let(:writer) { described_class.new(schema) }

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
          let(:schema) { ::Mono::TestTableSchema.new(context: context) }
          let(:writer) { described_class.new(schema, **options) }

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

      context 'with row_type: :hash' do
        let(:options) do
          [
            { result_type: :hash }, # deprecated
            { row_type: :hash }
          ].sample
        end

        shared_examples 'to convert and write data' do
          it 'succeeds' do
            table = []
            writer.write(items, to: table)

            expect(table[0]).to eq(
              0 => 'ID',
              1 => 'Name',
              2 => 'Pet 1',
              3 => 'Pet 2',
              4 => 'Pet 3',
              5 => 'Q1',
              6 => 'Q2',
              7 => 'Q3'
            )

            expect(table[1]).to eq(
              0 => 1,
              1 => '太郎',
              2 => 'cat',
              3 => 'dog',
              4 => nil,
              5 => 'yes',
              6 => 'no',
              7 => 'yes'
            )

            expect(table[2]).to eq(
              0 => 2,
              1 => '花子',
              2 => 'rabbit',
              3 => 'turtle',
              4 => 'squirrel',
              5 => 'yes',
              6 => 'yes',
              7 => 'no'
            )

            expect(table[3]).to eq(
              0 => 3,
              1 => '次郎',
              2 => 'tiger',
              3 => 'elephant',
              4 => 'doragon',
              5 => 'no',
              6 => 'yes',
              7 => nil
            )
          end
        end

        context 'deprecated' do
          let(:schema) { ::Mono::TestTableSchema.new(context: context, **options) }
          let(:writer) { described_class.new(schema) }

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
          let(:schema) { ::Mono::TestTableSchema.new(context: context) }
          let(:writer) { described_class.new(schema, **options) }

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
      shared_examples 'to convert and write data with header' do
        it 'succeeds' do
          expect(@s).to eq "ID,Name,Pet 1,Pet 2,Pet 3,Q1,Q2,Q3\n" \
                          "1,太郎,cat,dog,,yes,no,yes\n" \
                          "2,花子,rabbit,turtle,squirrel,yes,yes,no\n" \
                          "3,次郎,tiger,elephant,doragon,no,yes,\n"
        end
      end

      shared_examples 'to convert and write data without header' do
        it 'succeeds' do
          expect(@s).to eq "1,太郎,cat,dog,,yes,no,yes\n" \
                          "2,花子,rabbit,turtle,squirrel,yes,yes,no\n" \
                          "3,次郎,tiger,elephant,doragon,no,yes,\n"
        end
      end

      before do
        schema = ::Mono::TestTableSchema.new(context: context)
        writer = described_class.new(schema, **options)
        @s = ::String.new
        writer.write(items, to: @s) do |row_values|
          row_values.join(',') + "\n"
        end
      end

      context 'when header is omitted' do
        let(:options) do
          [
            { header_omitted: true },
            { header: false }
          ].sample
        end

        context 'when passed array_items' do
          let(:items) { array_items }
          it_behaves_like 'to convert and write data without header'
        end

        context 'when passed lambda_items' do
          let(:items) { lambda_items }
          it_behaves_like 'to convert and write data without header'
        end

        context 'when passed enumerator_items' do
          let(:items) { enumerator_items }
          it_behaves_like 'to convert and write data without header'
        end
      end

      context 'when header is not omitted' do
        let(:options) do
          [
            { header_omitted: false },
            { header: true },
            {}
          ].sample
        end

        context 'when passed array_items' do
          let(:items) { array_items }
          it_behaves_like 'to convert and write data with header'
        end

        context 'when passed lambda_items' do
          let(:items) { lambda_items }
          it_behaves_like 'to convert and write data with header'
        end

        context 'when passed enumerator_items' do
          let(:items) { enumerator_items }
          it_behaves_like 'to convert and write data with header'
        end
      end
    end
  end
end
