# frozen_string_literal: true

RSpec.describe TableStructure::Schema::ContextBuilders do
  let(:context_builders) { described_class.new(builders) }

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
        name: ->(header, table) { "#{table[:name]}_#{header[:name]}" },
        key: :key1,
        value: ->(row, table) { "#{table[:name]}_#{row[:name]}" },
        size: 1
      )
    ]
  end

  describe '#build_for_table' do
    let(:builders) do
      {
        table: ::TableStructure::Schema::Definition::ContextBuilder.new(
          ->(context) { context.merge(name: 'table!') }
        )
      }
    end

    let(:table_context) { { name: 'table' } }

    let(:keys_generator) { nil }

    subject { context_builders.build_for_table(table_context) }

    it { is_expected.to eq(name: 'table!') }
  end

  describe '#extend_methods_for' do
    let(:builders) do
      {
        header: ->(context) { context.merge(name: 'header!') },
        row: ->(context) { context.merge(name: 'row!') }
      }
    end

    let(:table_context) { { name: 'table' } }
    let(:header_context) { { name: 'header' } }
    let(:row_context) { { name: 'row' } }

    let(:keys_generator) { nil }

    before { context_builders.extend_methods_for(table) }

    it { expect(table.header(context: header_context)).to eq ['table_header!'] }
    it { expect(table.row(context: row_context)).to eq ['table_row!'] }
  end
end
