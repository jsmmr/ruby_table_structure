# frozen_string_literal: true

RSpec.describe TableStructure::Table::ContextBuilder do
  describe '.create_module' do
    let(:table_class) do
      Class.new do
        def header(context:)
          ["#{context[:name]}: #{context[:value]}"]
        end

        def data(context:)
          ["#{context[:name]}: #{context[:value]}"]
        end
      end
    end

    let(:table) do
      builders = {
        header: ::TableStructure::Schema::Definition::ContextBuilder.new do |context|
          context.merge(value: 'header')
        end,
        row: ::TableStructure::Schema::Definition::ContextBuilder.new do |context|
          context.merge(value: 'row')
        end
      }

      described_class.create_module(
        builders,
        context: { name: 'table' }
      ) do |mod|
        table_class.new.extend mod
      end
    end

    let(:header_context) { { name: 'header' } }
    let(:data_context) { { name: 'body' } }

    it { expect(table.header(context: header_context)).to eq ['header: header'] }
    it { expect(table.data(context: data_context)).to eq ['body: row'] }
  end
end
