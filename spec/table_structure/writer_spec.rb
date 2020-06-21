# frozen_string_literal: true

RSpec.describe TableStructure::Writer do
  describe '#write' do
    include_context 'questions'
    include_context 'users'

    let(:context) { { questions: questions } }

    let(:array_items) { users }

    let(:enumerator_items) do
      ::Enumerator.new { |y| array_items.each { |item| y << item } }
    end

    context 'when output to CSV file' do
      include_context 'table_structured_array_with_stringified'

      shared_examples 'to convert and write data' do
        it 'succeeds' do
          require 'csv'
          require 'tempfile'

          schema = ::Mono::TestTableSchema.new(context: context) do
            column_builder :to_s do |val, *|
              val.to_s
            end
          end
          writer = described_class.new(schema)

          tf = ::Tempfile.open do |fp|
            writer.write(items, to: ::CSV.new(fp), &converter)
            fp
          end

          table = ::CSV.read(tf.path, **csv_options)

          expect(table[0]).to eq header_row
          expect(table[1]).to eq body_row_taro
          expect(table[2]).to eq body_row_hanako
          expect(table[3]).to eq body_row_jiro
        end
      end

      context 'when CSV encoding is UTF-8' do
        let(:csv_options) { {} }
        let(:converter) { ->(values) { values } }

        context 'when passed array_items' do
          let(:items) { array_items }
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

        context 'when passed enumerator_items' do
          let(:items) { enumerator_items }
          it_behaves_like 'to convert and write data'
        end
      end
    end

    context 'when output to yielder' do
      include_context 'table_structured_array'

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

          expect(enum.next).to eq header_row
          expect(times).to eq 1

          expect(enum.next).to eq body_row_taro
          expect(times).to eq 2

          expect(enum.next).to eq body_row_hanako
          expect(times).to eq 3

          expect(enum.next).to eq body_row_jiro
          expect(times).to eq 4
        end
      end

      context 'when passed array_items' do
        let(:items) { array_items }
        it_behaves_like 'to convert and write data'
      end

      context 'when passed enumerator_items' do
        let(:items) { enumerator_items }
        it_behaves_like 'to convert and write data'
      end
    end

    context 'when output to array' do
      context 'with row_type: :array' do
        include_context 'table_structured_array'

        let(:options) do
          { row_type: :array }
        end

        shared_examples 'to convert and write data' do
          it 'succeeds' do
            table = []
            writer.write(items, to: table)

            expect(table[0]).to eq header_row
            expect(table[1]).to eq body_row_taro
            expect(table[2]).to eq body_row_hanako
            expect(table[3]).to eq body_row_jiro
          end
        end

        let(:schema) { ::Mono::TestTableSchema.new(context: context) }
        let(:writer) { described_class.new(schema, **options) }

        context 'when passed array_items' do
          let(:items) { array_items }
          it_behaves_like 'to convert and write data'
        end

        context 'when passed enumerator_items' do
          let(:items) { enumerator_items }
          it_behaves_like 'to convert and write data'
        end
      end

      context 'with row_type: :hash' do
        include_context 'table_structured_hash_with_index_keys'

        let(:options) do
          { row_type: :hash }
        end

        shared_examples 'to convert and write data' do
          it 'succeeds' do
            table = []
            writer.write(items, to: table)

            expect(table[0]).to eq header_row
            expect(table[1]).to eq body_row_taro
            expect(table[2]).to eq body_row_hanako
            expect(table[3]).to eq body_row_jiro
          end
        end

        let(:schema) { ::Mono::TestTableSchema.new(context: context) }
        let(:writer) { described_class.new(schema, **options) }

        context 'when passed array_items' do
          let(:items) { array_items }
          it_behaves_like 'to convert and write data'
        end

        context 'when passed enumerator_items' do
          let(:items) { enumerator_items }
          it_behaves_like 'to convert and write data'
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
          { header: false }
        end

        context 'when passed array_items' do
          let(:items) { array_items }
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
            { header: true },
            {}
          ].sample
        end

        context 'when passed array_items' do
          let(:items) { array_items }
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
