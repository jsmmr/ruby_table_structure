RSpec.describe TableStructure::Schema::Column do

  context 'pattern 1' do
    let(:params) {
      {}
    }

    let(:column) { described_class.new(params) }

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
    let(:params) {
      {
        name: 'Name',
        value: 'Taro',
      }
    }

    let(:column) { described_class.new(params) }

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
    let(:params) {
      {
        name: 'Name',
        value: ->(_row, _table) { _row + _table },
      }
    }

    let(:column) { described_class.new(params) }

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
    let(:params) {
      {
        name: ->(row, table) { row + table },
        value: 'Taro',
      }
    }

    describe '.new' do
      it 'raises error' do
        expect{ described_class.new(params) }.to raise_error '"size" must be specified, because column size cannot be determined.'
      end
    end
  end

  context 'pattern 5' do
    let(:params) {
      {
        name: ->(row, table) { row + table },
        value: 'Taro',
        size: 1,
      }
    }

    let(:column) { described_class.new(params) }

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
    let(:params) {
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: ['cat', 'dog'],
      }
    }

    let(:column) { described_class.new(params) }

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
    let(:params) {
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: ['tiger', 'elephant', 'doragon'],
      }
    }

    let(:column) { described_class.new(params) }

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
    let(:params) {
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: ['rabbit', 'turtle', 'squirrel', 'giraffe'],
      }
    }

    let(:column) { described_class.new(params) }

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
    let(:params) {
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: [],
      }
    }

    let(:column) { described_class.new(params) }

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
    let(:params) {
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: nil,
      }
    }

    let(:column) { described_class.new(params) }

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
    let(:params) {
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: ['tiger', 'elephant', 'doragon'],
        size: 3,
      }
    }

    let(:column) { described_class.new(params) }

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
    let(:params) {
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: ['tiger', 'elephant', 'doragon'],
        size: 2,
      }
    }

    let(:column) { described_class.new(params) }

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
    let(:params) {
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: ['tiger', 'elephant', 'doragon'],
        size: 4,
      }
    }

    let(:column) { described_class.new(params) }

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
    let(:params) {
      {
        name: ['Pet 1', 'Pet 2', 'Pet 3'],
        value: ['tiger', 'elephant', 'doragon'],
        size: 0,
      }
    }

    describe '.new' do
      it 'raises error' do
        expect{ described_class.new(params) }.to raise_error '"size" must be positive.'
      end
    end
  end
end
