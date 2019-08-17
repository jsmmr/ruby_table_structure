# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Column do
  let(:group_index) { 0 }

  context 'pattern 1' do
    let(:definition) do
      {}
    end

    let(:column) { described_class.new(definition, group_index) }

    describe '#name' do
      subject { column.name(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to be_nil }
    end

    describe '#key' do
      subject { column.key }

      it { is_expected.to be_nil }
    end

    describe '#value' do
      subject { column.value(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to be_nil }
    end
  end

  context 'pattern 2' do
    let(:definition) do
      {
        name: 'Name',
        value: 'Taro'
      }
    end

    let(:column) { described_class.new(definition, group_index) }

    describe '#name' do
      subject { column.name(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq 'Name' }
    end

    describe '#key' do
      subject { column.key }

      it { is_expected.to be_nil }
    end

    describe '#value' do
      subject { column.value(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq 'Taro' }
    end
  end

  context 'pattern 3' do
    let(:definition) do
      {
        name: 'Name',
        value: ->(_row, _table) { _row + _table }
      }
    end

    let(:column) { described_class.new(definition, group_index) }

    describe '#name' do
      subject { column.name(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq 'Name' }
    end

    describe '#key' do
      subject { column.key }

      it { is_expected.to be_nil }
    end

    describe '#value' do
      subject { column.value(row_context, table_context) }

      let(:row_context) { 'Ta' }
      let(:table_context) { 'ro' }

      it { is_expected.to eq 'Taro' }
    end
  end

  context 'pattern 4' do
    let(:definition) do
      {
        name: ->(row, table) { row + table },
        value: 'Taro'
      }
    end

    describe '.new' do
      it 'raises error' do
        expect { described_class.new(definition, group_index) }
          .to raise_error '"size" must be specified, because column size cannot be determined. [defined position: 1]'
      end
    end
  end

  context 'pattern 5' do
    let(:definition) do
      {
        name: ->(row, table) { row + table },
        value: 'Taro',
        size: 1
      }
    end

    let(:column) { described_class.new(definition, group_index) }

    describe '#name' do
      subject { column.name(header_context, table_context) }

      let(:header_context) { 'Na' }
      let(:table_context) { 'me' }

      it { is_expected.to eq 'Name' }
    end

    describe '#key' do
      subject { column.key }

      it { is_expected.to be_nil }
    end

    describe '#value' do
      subject { column.value(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq 'Taro' }
    end
  end

  context 'pattern 6' do
    let(:definition) do
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: %w[cat dog]
      }
    end

    let(:column) { described_class.new(definition, group_index) }

    describe '#name' do
      subject { column.name(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Pet 1', 'Pet 2', 'Pet 3'] }
    end

    describe '#key' do
      subject { column.key }

      it { is_expected.to eq [nil, nil, nil] }
    end

    describe '#value' do
      subject { column.value(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['cat', 'dog', nil] }
    end
  end

  context 'pattern 7' do
    let(:definition) do
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: %w[tiger elephant doragon]
      }
    end

    let(:column) { described_class.new(definition, group_index) }

    describe '#name' do
      subject { column.name(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Pet 1', 'Pet 2', 'Pet 3'] }
    end

    describe '#key' do
      subject { column.key }

      it { is_expected.to eq [nil, nil, nil] }
    end

    describe '#value' do
      subject { column.value(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq %w[tiger elephant doragon] }
    end
  end

  context 'pattern 8' do
    let(:definition) do
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: %w[rabbit turtle squirrel giraffe]
      }
    end

    let(:column) { described_class.new(definition, group_index) }

    describe '#name' do
      subject { column.name(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Pet 1', 'Pet 2', 'Pet 3'] }
    end

    describe '#key' do
      subject { column.key }

      it { is_expected.to eq [nil, nil, nil] }
    end

    describe '#value' do
      subject { column.value(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq %w[rabbit turtle squirrel] }
    end
  end

  context 'pattern 9' do
    let(:definition) do
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: []
      }
    end

    let(:column) { described_class.new(definition, group_index) }

    describe '#name' do
      subject { column.name(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Pet 1', 'Pet 2', 'Pet 3'] }
    end

    describe '#key' do
      subject { column.key }

      it { is_expected.to eq [nil, nil, nil] }
    end

    describe '#value' do
      subject { column.value(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq [nil, nil, nil] }
    end
  end

  context 'pattern 10' do
    let(:definition) do
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: nil
      }
    end

    let(:column) { described_class.new(definition, group_index) }

    describe '#name' do
      subject { column.name(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Pet 1', 'Pet 2', 'Pet 3'] }
    end

    describe '#key' do
      subject { column.key }

      it { is_expected.to eq [nil, nil, nil] }
    end

    describe '#value' do
      subject { column.value(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq [nil, nil, nil] }
    end
  end

  context 'pattern 11' do
    let(:definition) do
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: %w[tiger elephant doragon],
        size: 3
      }
    end

    let(:column) { described_class.new(definition, group_index) }

    describe '#name' do
      subject { column.name(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Pet 1', 'Pet 2', 'Pet 3'] }
    end

    describe '#key' do
      subject { column.key }

      it { is_expected.to eq [nil, nil, nil] }
    end

    describe '#value' do
      subject { column.value(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq %w[tiger elephant doragon] }
    end
  end

  context 'pattern 12' do
    let(:definition) do
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: %w[tiger elephant doragon],
        size: 2
      }
    end

    let(:column) { described_class.new(definition, group_index) }

    describe '#name' do
      subject { column.name(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Pet 1', 'Pet 2'] }
    end

    describe '#key' do
      subject { column.key }

      it { is_expected.to eq [nil, nil] }
    end

    describe '#value' do
      subject { column.value(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq %w[tiger elephant] }
    end
  end

  context 'pattern 13' do
    let(:definition) do
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: %w[tiger elephant doragon],
        size: 4
      }
    end

    let(:column) { described_class.new(definition, group_index) }

    describe '#name' do
      subject { column.name(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Pet 1', 'Pet 2', 'Pet 3', nil] }
    end

    describe '#key' do
      subject { column.key }

      it { is_expected.to eq [nil, nil, nil, nil] }
    end

    describe '#value' do
      subject { column.value(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['tiger', 'elephant', 'doragon', nil] }
    end
  end

  context 'pattern 14' do
    let(:definition) do
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: %w[tiger elephant doragon],
        size: 0
      }
    end

    describe '.new' do
      it 'raises error' do
        expect { described_class.new(definition, group_index) }
          .to raise_error '"size" must be positive. [defined position: 1]'
      end
    end
  end

  context 'pattern 15' do
    let(:definition) do
      {
        name: 'Name',
        key: %i[first_name last_name],
        value: %w[Taro Momo]
      }
    end

    let(:column) { described_class.new(definition, group_index) }

    describe '#name' do
      subject { column.name(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Name', nil] }
    end

    describe '#key' do
      subject { column.key }

      it { is_expected.to eq %i[first_name last_name] }
    end

    describe '#value' do
      subject { column.value(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq %w[Taro Momo] }
    end
  end

  context 'pattern 16' do
    let(:definition) do
      {
        name: ['First name', 'Last name'],
        key: [:name],
        value: %w[Taro Momo]
      }
    end

    let(:column) { described_class.new(definition, group_index) }

    describe '#name' do
      subject { column.name(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['First name', 'Last name'] }
    end

    describe '#key' do
      subject { column.key }

      it { is_expected.to eq [:name, nil] }
    end

    describe '#value' do
      subject { column.value(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq %w[Taro Momo] }
    end
  end

  context 'pattern 17' do
    let(:definition) do
      {
        name: ->(*) { 'Name' },
        key: %i[first_name last_name],
        value: %w[Taro Momo]
      }
    end

    let(:column) { described_class.new(definition, group_index) }

    describe '#name' do
      subject { column.name(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Name', nil] }
    end

    describe '#key' do
      subject { column.key }

      it { is_expected.to eq %i[first_name last_name] }
    end

    describe '#value' do
      subject { column.value(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq %w[Taro Momo] }
    end
  end
end
