RSpec.describe TableStructure::Schema::Column do

  let(:group_index) { 0 }

  context 'pattern 1' do
    let(:definition) {
      {}
    }

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
    let(:definition) {
      {
        name: 'Name',
        value: 'Taro',
      }
    }

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
    let(:definition) {
      {
        name: 'Name',
        value: ->(_row, _table) { _row + _table },
      }
    }

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
    let(:definition) {
      {
        name: ->(row, table) { row + table },
        value: 'Taro',
      }
    }

    describe '.new' do
      it 'raises error' do
        expect { described_class.new(definition, group_index) }
          .to raise_error '"size" must be specified, because column size cannot be determined. [defined position: 1]'
      end
    end
  end

  context 'pattern 5' do
    let(:definition) {
      {
        name: ->(row, table) { row + table },
        value: 'Taro',
        size: 1,
      }
    }

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
    let(:definition) {
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: ['cat', 'dog'],
      }
    }

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
    let(:definition) {
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: ['tiger', 'elephant', 'doragon'],
      }
    }

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

      it { is_expected.to eq ['tiger', 'elephant', 'doragon'] }
    end
  end

  context 'pattern 8' do
    let(:definition) {
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: ['rabbit', 'turtle', 'squirrel', 'giraffe'],
      }
    }

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

      it { is_expected.to eq ['rabbit', 'turtle', 'squirrel'] }
    end
  end

  context 'pattern 9' do
    let(:definition) {
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: [],
      }
    }

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
    let(:definition) {
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: nil,
      }
    }

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
    let(:definition) {
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: ['tiger', 'elephant', 'doragon'],
        size: 3,
      }
    }

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

      it { is_expected.to eq ['tiger', 'elephant', 'doragon'] }
    end
  end

  context 'pattern 12' do
    let(:definition) {
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: ['tiger', 'elephant', 'doragon'],
        size: 2,
      }
    }

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

      it { is_expected.to eq ['tiger', 'elephant'] }
    end
  end

  context 'pattern 13' do
    let(:definition) {
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: ['tiger', 'elephant', 'doragon'],
        size: 4,
      }
    }

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
    let(:definition) {
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: ['tiger', 'elephant', 'doragon'],
        size: 0,
      }
    }

    describe '.new' do
      it 'raises error' do
        expect { described_class.new(definition, group_index) }
          .to raise_error '"size" must be positive. [defined position: 1]'
      end
    end
  end

  context 'pattern 15' do
    let(:definition) {
      {
        name: 'Name',
        key: [:first_name, :last_name],
        value: ['Taro', 'Momo']
      }
    }

    let(:column) { described_class.new(definition, group_index) }

    describe '#name' do
      subject { column.name(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Name', nil] }
    end

    describe '#key' do
      subject { column.key }

      it { is_expected.to eq [:first_name, :last_name] }
    end

    describe '#value' do
      subject { column.value(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Taro', 'Momo'] }
    end
  end

  context 'pattern 16' do
    let(:definition) {
      {
        name: ['First name', 'Last name'],
        key: [:name],
        value: ['Taro', 'Momo']
      }
    }

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

      it { is_expected.to eq ['Taro', 'Momo'] }
    end
  end

  context 'pattern 17' do
    let(:definition) {
      {
        name: ->(*) { 'Name' },
        key: [:first_name, :last_name],
        value: ['Taro', 'Momo']
      }
    }

    let(:column) { described_class.new(definition, group_index) }

    describe '#name' do
      subject { column.name(header_context, table_context) }

      let(:header_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Name', nil] }
    end

    describe '#key' do
      subject { column.key }

      it { is_expected.to eq [:first_name, :last_name] }
    end

    describe '#value' do
      subject { column.value(row_context, table_context) }

      let(:row_context) { nil }
      let(:table_context) { nil }

      it { is_expected.to eq ['Taro', 'Momo'] }
    end
  end
end
