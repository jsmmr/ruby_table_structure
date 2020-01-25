# frozen_string_literal: true

RSpec.describe TableStructure::Schema::ColumnConverters do
  let(:column_converters) { described_class.new(converters) }

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
        name: column_name,
        key: :key1,
        value: 'row_value',
        size: 1
      )
    ]
  end

  let(:column_name) { 'name_value' }

  describe '#extend_methods_for' do
    let(:converters) do
      {
        test: ::TableStructure::Schema::Definition::ColumnConverter.new(
          ->(val, row, table) { "#{table[:name]}_#{row[:name]}_#{val}" },
          **converter_options
        )
      }
    end

    let(:converter_options) { { header: true, body: true } }

    let(:keys_generator) { nil }
    let(:table_context) { { name: 'table' } }
    let(:header_context) { { name: 'header' } }
    let(:row_context) { { name: 'row' } }

    let(:options) { { name_prefix: nil, name_suffix: nil } }

    before { column_converters.extend_methods_for(table, **options) }

    context 'when converter options include `header: true`' do
      let(:converter_options) { { header: true, body: true } }

      it { expect(table.header(context: header_context)).to eq ['table_header_name_value'] }
      it { expect(table.row(context: row_context)).to eq ['table_row_row_value'] }
    end

    context 'when converter options include `header: false`' do
      let(:converter_options) { { header: false, body: true } }

      it { expect(table.header(context: header_context)).to eq ['name_value'] }
      it { expect(table.row(context: row_context)).to eq ['table_row_row_value'] }
    end

    context 'when converter options include `row: true`' do
      let(:converter_options) { { header: true, body: true } }

      it { expect(table.header(context: header_context)).to eq ['table_header_name_value'] }
      it { expect(table.row(context: row_context)).to eq ['table_row_row_value'] }
    end

    context 'when converter options include `row: false`' do
      let(:converter_options) { { header: true, body: false } }

      it { expect(table.header(context: header_context)).to eq ['table_header_name_value'] }
      it { expect(table.row(context: row_context)).to eq ['row_value'] }
    end

    context 'when header does not include nil' do
      context 'when :name_prefix option is specified' do
        let(:options) { { name_prefix: 'prefix_', name_suffix: nil } }

        it { expect(table.header(context: header_context)).to eq ['prefix_table_header_name_value'] }
        it { expect(table.row(context: row_context)).to eq ['table_row_row_value'] }
      end

      context 'when :name_suffix option is specified' do
        let(:options) { { name_prefix: nil, name_suffix: '_suffix' } }

        it { expect(table.header(context: header_context)).to eq ['table_header_name_value_suffix'] }
        it { expect(table.row(context: row_context)).to eq ['table_row_row_value'] }
      end
    end

    context 'when header includes nil' do
      let(:converters) { {} }
      let(:column_name) { nil }

      context 'when :name_prefix option is specified' do
        let(:options) { { name_prefix: 'prefix_', name_suffix: nil } }

        it { expect(table.header(context: header_context)).to eq [nil] }
        it { expect(table.row(context: row_context)).to eq ['row_value'] }
      end

      context 'when :name_suffix option is specified' do
        let(:options) { { name_prefix: nil, name_suffix: '_suffix' } }

        it { expect(table.header(context: header_context)).to eq [nil] }
        it { expect(table.row(context: row_context)).to eq ['row_value'] }
      end
    end
  end
end
