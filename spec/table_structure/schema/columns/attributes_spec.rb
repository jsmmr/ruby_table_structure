# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Columns::Attributes do
  context 'pattern 1' do
    let(:attrs) do
      {
        name: nil,
        key: nil,
        value: nil,
        size: 1
      }
    end

    let(:column) { described_class.new(**attrs) }

    describe '#names' do
      subject { column.names(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to be_nil }
    end

    describe '#keys' do
      subject { column.keys }

      it { is_expected.to eq [nil] }
    end

    describe '#values' do
      subject { column.values(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to be_nil }
    end

    describe '#size' do
      subject { column.size }

      it { is_expected.to eq 1 }
    end

    describe '#name_callable?' do
      subject { column.name_callable? }
      it { is_expected.to eq false }
    end

    describe '#value_callable?' do
      subject { column.value_callable? }
      it { is_expected.to eq false }
    end
  end

  context 'pattern 2' do
    let(:attrs) do
      {
        name: 'Name',
        key: nil,
        value: 'Taro',
        size: 1
      }
    end

    let(:column) { described_class.new(**attrs) }

    describe '#names' do
      subject { column.names(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq 'Name' }
    end

    describe '#keys' do
      subject { column.keys }

      it { is_expected.to eq [nil] }
    end

    describe '#values' do
      subject { column.values(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq 'Taro' }
    end

    describe '#size' do
      subject { column.size }

      it { is_expected.to eq 1 }
    end

    describe '#name_callable?' do
      subject { column.name_callable? }
      it { is_expected.to eq false }
    end

    describe '#value_callable?' do
      subject { column.value_callable? }
      it { is_expected.to eq false }
    end
  end

  context 'pattern 3' do
    let(:attrs) do
      {
        name: 'Name',
        key: nil,
        value: ->(_row, _table) { _row + _table },
        size: 1
      }
    end

    let(:column) { described_class.new(**attrs) }

    describe '#names' do
      subject { column.names(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq 'Name' }
    end

    describe '#keys' do
      subject { column.keys }

      it { is_expected.to eq [nil] }
    end

    describe '#values' do
      subject { column.values(row_context, table_context) }

      let(:row_context) { 'Ta' }
      let(:table_context) { 'ro' }

      it { is_expected.to eq 'Taro' }
    end

    describe '#size' do
      subject { column.size }

      it { is_expected.to eq 1 }
    end

    describe '#name_callable?' do
      subject { column.name_callable? }
      it { is_expected.to eq false }
    end

    describe '#value_callable?' do
      subject { column.value_callable? }
      it { is_expected.to eq true }
    end
  end

  context 'pattern 4' do
    let(:attrs) do
      {
        name: ->(row, table) { row + table },
        key: nil,
        value: 'Taro',
        size: 1
      }
    end

    let(:column) { described_class.new(**attrs) }

    describe '#names' do
      subject { column.names(header_context, table_context) }

      let(:header_context) { 'Na' }
      let(:table_context) { 'me' }

      it { is_expected.to eq 'Name' }
    end

    describe '#keys' do
      subject { column.keys }

      it { is_expected.to eq [nil] }
    end

    describe '#values' do
      subject { column.values(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq 'Taro' }
    end

    describe '#size' do
      subject { column.size }

      it { is_expected.to eq 1 }
    end

    describe '#name_callable?' do
      subject { column.name_callable? }
      it { is_expected.to eq true }
    end

    describe '#value_callable?' do
      subject { column.value_callable? }
      it { is_expected.to eq false }
    end
  end

  context 'pattern 5' do
    let(:attrs) do
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        key: nil,
        value: %w[cat dog],
        size: 3
      }
    end

    let(:column) { described_class.new(**attrs) }

    describe '#names' do
      subject { column.names(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Pet 1', 'Pet 2', 'Pet 3'] }
    end

    describe '#keys' do
      subject { column.keys }

      it { is_expected.to eq [nil, nil, nil] }
    end

    describe '#values' do
      subject { column.values(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['cat', 'dog', nil] }
    end

    describe '#size' do
      subject { column.size }

      it { is_expected.to eq 3 }
    end

    describe '#name_callable?' do
      subject { column.name_callable? }
      it { is_expected.to eq false }
    end

    describe '#value_callable?' do
      subject { column.value_callable? }
      it { is_expected.to eq false }
    end
  end

  context 'pattern 6' do
    let(:attrs) do
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        key: nil,
        value: %w[tiger elephant doragon],
        size: 3
      }
    end

    let(:column) { described_class.new(**attrs) }

    describe '#names' do
      subject { column.names(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Pet 1', 'Pet 2', 'Pet 3'] }
    end

    describe '#keys' do
      subject { column.keys }

      it { is_expected.to eq [nil, nil, nil] }
    end

    describe '#values' do
      subject { column.values(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq %w[tiger elephant doragon] }
    end

    describe '#size' do
      subject { column.size }

      it { is_expected.to eq 3 }
    end

    describe '#name_callable?' do
      subject { column.name_callable? }
      it { is_expected.to eq false }
    end

    describe '#value_callable?' do
      subject { column.value_callable? }
      it { is_expected.to eq false }
    end
  end

  context 'pattern 7' do
    let(:attrs) do
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        key: nil,
        value: %w[rabbit turtle squirrel giraffe],
        size: 3
      }
    end

    let(:column) { described_class.new(**attrs) }

    describe '#names' do
      subject { column.names(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Pet 1', 'Pet 2', 'Pet 3'] }
    end

    describe '#keys' do
      subject { column.keys }

      it { is_expected.to eq [nil, nil, nil] }
    end

    describe '#values' do
      subject { column.values(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq %w[rabbit turtle squirrel] }
    end

    describe '#size' do
      subject { column.size }

      it { is_expected.to eq 3 }
    end

    describe '#name_callable?' do
      subject { column.name_callable? }
      it { is_expected.to eq false }
    end

    describe '#value_callable?' do
      subject { column.value_callable? }
      it { is_expected.to eq false }
    end
  end

  context 'pattern 8' do
    let(:attrs) do
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        key: nil,
        value: [],
        size: 3
      }
    end

    let(:column) { described_class.new(**attrs) }

    describe '#names' do
      subject { column.names(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Pet 1', 'Pet 2', 'Pet 3'] }
    end

    describe '#keys' do
      subject { column.keys }

      it { is_expected.to eq [nil, nil, nil] }
    end

    describe '#values' do
      subject { column.values(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq [nil, nil, nil] }
    end

    describe '#size' do
      subject { column.size }

      it { is_expected.to eq 3 }
    end

    describe '#name_callable?' do
      subject { column.name_callable? }
      it { is_expected.to eq false }
    end

    describe '#value_callable?' do
      subject { column.value_callable? }
      it { is_expected.to eq false }
    end
  end

  context 'pattern 9' do
    let(:attrs) do
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        key: nil,
        value: nil,
        size: 3
      }
    end

    let(:column) { described_class.new(**attrs) }

    describe '#names' do
      subject { column.names(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Pet 1', 'Pet 2', 'Pet 3'] }
    end

    describe '#keys' do
      subject { column.keys }

      it { is_expected.to eq [nil, nil, nil] }
    end

    describe '#values' do
      subject { column.values(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq [nil, nil, nil] }
    end

    describe '#size' do
      subject { column.size }

      it { is_expected.to eq 3 }
    end

    describe '#name_callable?' do
      subject { column.name_callable? }
      it { is_expected.to eq false }
    end

    describe '#value_callable?' do
      subject { column.value_callable? }
      it { is_expected.to eq false }
    end
  end

  context 'pattern 10' do
    let(:attrs) do
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        key: %i[pet1 pet2 pet3],
        value: %w[tiger elephant doragon],
        size: 1
      }
    end

    let(:column) { described_class.new(**attrs) }

    describe '#names' do
      subject { column.names(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Pet 1'] }
    end

    describe '#keys' do
      subject { column.keys }

      it { is_expected.to eq %i[pet1] }
    end

    describe '#values' do
      subject { column.values(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq %w[tiger] }
    end

    describe '#size' do
      subject { column.size }

      it { is_expected.to eq 1 }
    end

    describe '#name_callable?' do
      subject { column.name_callable? }
      it { is_expected.to eq false }
    end

    describe '#value_callable?' do
      subject { column.value_callable? }
      it { is_expected.to eq false }
    end
  end

  context 'pattern 11' do
    let(:attrs) do
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        key: nil,
        value: %w[tiger elephant doragon],
        size: 2
      }
    end

    let(:column) { described_class.new(**attrs) }

    describe '#names' do
      subject { column.names(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Pet 1', 'Pet 2'] }
    end

    describe '#keys' do
      subject { column.keys }

      it { is_expected.to eq [nil, nil] }
    end

    describe '#values' do
      subject { column.values(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq %w[tiger elephant] }
    end

    describe '#size' do
      subject { column.size }

      it { is_expected.to eq 2 }
    end

    describe '#name_callable?' do
      subject { column.name_callable? }
      it { is_expected.to eq false }
    end

    describe '#value_callable?' do
      subject { column.value_callable? }
      it { is_expected.to eq false }
    end
  end

  context 'pattern 12' do
    let(:attrs) do
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        key: nil,
        value: %w[tiger elephant doragon],
        size: 4
      }
    end

    let(:column) { described_class.new(**attrs) }

    describe '#names' do
      subject { column.names(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Pet 1', 'Pet 2', 'Pet 3', nil] }
    end

    describe '#keys' do
      subject { column.keys }

      it { is_expected.to eq [nil, nil, nil, nil] }
    end

    describe '#values' do
      subject { column.values(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['tiger', 'elephant', 'doragon', nil] }
    end

    describe '#size' do
      subject { column.size }

      it { is_expected.to eq 4 }
    end

    describe '#name_callable?' do
      subject { column.name_callable? }
      it { is_expected.to eq false }
    end

    describe '#value_callable?' do
      subject { column.value_callable? }
      it { is_expected.to eq false }
    end
  end

  context 'pattern 13' do
    let(:attrs) do
      {
        name: 'Name',
        key: %i[first_name last_name],
        value: %w[Taro Momo],
        size: 2
      }
    end

    let(:column) { described_class.new(**attrs) }

    describe '#names' do
      subject { column.names(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Name', nil] }
    end

    describe '#keys' do
      subject { column.keys }

      it { is_expected.to eq %i[first_name last_name] }
    end

    describe '#values' do
      subject { column.values(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq %w[Taro Momo] }
    end

    describe '#size' do
      subject { column.size }

      it { is_expected.to eq 2 }
    end

    describe '#name_callable?' do
      subject { column.name_callable? }
      it { is_expected.to eq false }
    end

    describe '#value_callable?' do
      subject { column.value_callable? }
      it { is_expected.to eq false }
    end
  end

  context 'pattern 15' do
    let(:attrs) do
      {
        name: ->(*) { 'Name' },
        key: %i[first_name last_name],
        value: %w[Taro Momo],
        size: 2
      }
    end

    let(:column) { described_class.new(**attrs) }

    describe '#names' do
      subject { column.names(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Name', nil] }
    end

    describe '#keys' do
      subject { column.keys }

      it { is_expected.to eq %i[first_name last_name] }
    end

    describe '#values' do
      subject { column.values(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq %w[Taro Momo] }
    end

    describe '#size' do
      subject { column.size }

      it { is_expected.to eq 2 }
    end

    describe '#name_callable?' do
      subject { column.name_callable? }
      it { is_expected.to eq true }
    end

    describe '#value_callable?' do
      subject { column.value_callable? }
      it { is_expected.to eq false }
    end
  end
end
