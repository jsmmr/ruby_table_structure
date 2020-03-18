# frozen_string_literal: true

RSpec.describe TableStructure::Table::ColumnConverter do
  describe '.create_module' do
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

    let(:table) do
      converters = {
        test: ::TableStructure::Schema::Definition::ColumnConverter.new(
          ->(val, row, table) { "#{table[:name]}_#{row[:name]}_#{val}" },
          **converter_options
        )
      }

      described_class.create_module(
        converters,
        context: { name: 'table' }
      ) do |mod|
        table_class.new.extend mod
      end
    end

    let(:header_context) { { name: 'header' } }
    let(:data_context) { { name: 'body' } }

    context 'when converter options include `header: true`' do
      let(:converter_options) { { header: true } }

      it { expect(table.header(context: header_context)).to eq ['table_header_name'] }
    end

    context 'when converter options include `header: false`' do
      let(:converter_options) { { header: false } }

      it { expect(table.header(context: header_context)).to eq ['name'] }
    end

    context 'when converter options include `body: true`' do
      let(:converter_options) { { body: true } }

      it { expect(table.data(context: data_context)).to eq ['table_body_value'] }
    end

    context 'when converter options include `body: false`' do
      let(:converter_options) { { body: false } }

      it { expect(table.data(context: data_context)).to eq ['value'] }
    end
  end
end
