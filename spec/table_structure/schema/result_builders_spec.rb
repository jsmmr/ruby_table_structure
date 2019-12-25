# frozen_string_literal: true

RSpec.describe TableStructure::Schema::ResultBuilders do
  let(:result_builders) { described_class.new(builders) }

  let(:table) { TableStructure::Schema::Table.new(columns, table_context, table_options) }

  let(:columns) do
    [
      TableStructure::Schema::Column::Attrs.new(
        name: 'name_value',
        key: :key1,
        value: 'row_value',
        size: 1
      )
    ]
  end

  describe '#extend_methods_for' do
    let(:builders) do
      {
        test1: {
          callable: lambda do |vals, _keys, row, table|
            vals.map { |val| "#{table[:name]}_#{row[:name]}_#{val}" }
          end,
          options: { enabled_result_types: %i[array] }
        },
        test2: {
          callable: ->(vals, keys, *) { keys.zip(vals).to_h },
          options: { enabled_result_types: %i[array] }
        },
        test3: {
          callable: ->(vals, *) { OpenStruct.new(vals) },
          options: { enabled_result_types: %i[hash] }
        }
      }
    end

    let(:builder_options) { { enabled_result_types: %i[array] } }

    let(:table_context) { { name: 'table' } }
    let(:header_context) { { name: 'header' } }
    let(:row_context) { { name: 'row' } }

    let(:table_options) { {} }

    before { result_builders.extend_methods_for(table, result_type: result_type) }

    context 'when table options include `result_type: array`' do
      let(:result_type) { :array }

      it { expect(table.header(context: header_context)).to eq(key1: 'table_header_name_value') }
      it { expect(table.row(context: row_context)).to eq(key1: 'table_row_row_value') }
    end

    context 'when table options include `result_type: hash`' do
      let(:result_type) { :hash }

      it { expect(table.header(context: header_context)).to eq OpenStruct.new(key1: 'name_value') }
      it { expect(table.row(context: row_context)).to eq OpenStruct.new(key1: 'row_value') }
    end
  end
end
