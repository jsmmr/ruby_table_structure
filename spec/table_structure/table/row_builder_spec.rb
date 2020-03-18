# frozen_string_literal: true

RSpec.describe TableStructure::Table::RowBuilder do
  describe '.create_module' do
    let(:table) do
      builders = {
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

      described_class.create_module(
        builders,
        row_type: row_type,
        keys: [:key1],
        context: { name: 'table' }
      ) do |mod|
        table_class.new.extend mod
      end
    end

    let(:header_context) { { name: 'header' } }
    let(:data_context) { { name: 'body' } }

    context 'when table options include `row_type: array`' do
      let(:row_type) { :array }
      let(:table_class) do
        Class.new do
          def header(context:)
            ['name']
          end

          def data(context:)
            ['value']
          end
        end
      end

      it { expect(table.header(context: header_context)).to eq(key1: 'table_header_name') }
      it { expect(table.data(context: data_context)).to eq(key1: 'table_body_value') }
    end

    context 'when table options include `row_type: hash`' do
      let(:row_type) { :hash }
      let(:table_class) do
        Class.new do
          def header(context:)
            { key1: 'name' }
          end

          def data(context:)
            { key1: 'value' }
          end
        end
      end

      require 'ostruct'

      it { expect(table.header(context: header_context)).to eq OpenStruct.new(key1: 'name') }
      it { expect(table.data(context: data_context)).to eq OpenStruct.new(key1: 'value') }
    end
  end
end
