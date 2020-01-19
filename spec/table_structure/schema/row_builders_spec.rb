# frozen_string_literal: true

RSpec.describe TableStructure::Schema::RowBuilders do
  let(:row_builders) { described_class.new(builders) }

  let(:table) do
    TableStructure::Schema::Table.new(
      columns: columns,
      context: table_context,
      keys_generator: keys_generator
    )
  end

  let(:columns) do
    [
      TableStructure::Schema::Columns::Attributes.new(
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
        test1: ::TableStructure::Schema::Definition::RowBuilder.new(
          lambda do |vals, _keys, row, table|
            vals.map { |val| "#{table[:name]}_#{row[:name]}_#{val}" }
          end,
          enabled_row_types: %i[array]
        ),
        test2: ::TableStructure::Schema::Definition::RowBuilder.new(
          ->(vals, keys, *) { keys.zip(vals).to_h },
          enabled_row_types: %i[array]
        ),
        test3: ::TableStructure::Schema::Definition::RowBuilder.new(
          ->(vals, *) { OpenStruct.new(vals) },
          enabled_row_types: %i[hash]
        )
      }
    end

    let(:builder_options) { { enabled_row_types: %i[array] } }

    let(:table_context) { { name: 'table' } }
    let(:header_context) { { name: 'header' } }
    let(:row_context) { { name: 'row' } }

    let(:keys_generator) { ::TableStructure::Schema::KeysGenerator.new }

    before { row_builders.extend_methods_for(table, row_type: row_type) }

    context 'when table options include `row_type: array`' do
      let(:row_type) { :array }

      it { expect(table.header(context: header_context)).to eq(key1: 'table_header_name_value') }
      it { expect(table.row(context: row_context)).to eq(key1: 'table_row_row_value') }
    end

    context 'when table options include `row_type: hash`' do
      let(:row_type) { :hash }

      it { expect(table.header(context: header_context)).to eq OpenStruct.new(key1: 'name_value') }
      it { expect(table.row(context: row_context)).to eq OpenStruct.new(key1: 'row_value') }
    end
  end
end
