# frozen_string_literal: true

RSpec.describe TableStructure::Schema::ColumnBuilderFactory do
  let(:factory) { described_class.new(builders, **options) }
  let(:row) { ::TableStructure::Schema::Row.new(keys, values, context) }

  let(:some_builders) do
    {
      capitalize: ::TableStructure::Utils::TypedProc.new(
        types: :header
      ) { |val, *| val.is_a?(String) ? val.capitalize : val },
      reverse: ::TableStructure::Utils::TypedProc.new(
        types: :body
      ) { |val, *| val.is_a?(String) ? val.reverse : val },
      swapcase: ::TableStructure::Utils::TypedProc.new(
        types: %i[header body]
      ) { |val, *| val.is_a?(String) ? val.swapcase : val }
    }
  end

  let(:no_builders) { {} }

  let(:no_options) do
    [
      {},
      { name_prefix: nil },
      { name_suffix: nil },
      { name_prefix: nil, name_suffix: nil }
    ]
      .sample
  end

  describe '#create_header_builder' do
    let(:keys) { [0, 1] }
    let(:values) { ['value', nil] }
    let(:context) { nil }

    let(:header_builder) { factory.create_header_builder }

    context 'when builders exist' do
      let(:builders) { some_builders }

      before { header_builder.call(row) }

      context 'when valid options are not set' do
        let(:options) { no_options }
        it { expect(row.values).to eq ['vALUE', nil] }
      end

      context 'when valid options are set' do
        context ':name_prefix' do
          let(:options) { { name_prefix: 'prefix_' } }
          it { expect(row.values).to eq ['prefix_vALUE', nil] }
        end

        context ':name_suffix' do
          let(:options) { { name_suffix: '_suffix' } }
          it { expect(row.values).to eq ['vALUE_suffix', nil] }
        end

        context ':name_prefix and :name_suffix' do
          let(:options) { { name_prefix: 'prefix_', name_suffix: '_suffix' } }
          it { expect(row.values).to eq ['prefix_vALUE_suffix', nil] }
        end
      end
    end

    context 'when builders do not exist' do
      let(:builders) { no_builders }

      context 'when valid options are not set' do
        let(:options) { no_options }
        it { expect(header_builder).to be_nil }
      end

      context 'when valid options are set' do
        before { header_builder.call(row) }

        context ':name_prefix' do
          let(:options) { { name_prefix: 'prefix_' } }
          it { expect(row.values).to eq ['prefix_value', nil] }
        end

        context ':name_suffix' do
          let(:options) { { name_suffix: '_suffix' } }
          it { expect(row.values).to eq ['value_suffix', nil] }
        end

        context ':name_prefix and :name_suffix' do
          let(:options) { { name_prefix: 'prefix_', name_suffix: '_suffix' } }
          it { expect(row.values).to eq ['prefix_value_suffix', nil] }
        end
      end
    end
  end

  describe '#create_data_builder' do
    let(:keys) { [0, 1] }
    let(:values) { ['value', nil] }
    let(:context) { nil }

    let(:data_builder) { factory.create_data_builder }

    let(:options) do
      [
        no_options,
        { name_prefix: 'prefix_' },
        { name_suffix: '_suffix' },
        { name_prefix: 'prefix_', name_suffix: '_suffix' }
      ]
        .sample
    end

    context 'when builders exist' do
      let(:builders) { some_builders }
      before { data_builder.call(row) }
      it { expect(row.values).to eq ['EULAV', nil] }
    end

    context 'when builders do not exist' do
      let(:builders) { no_builders }
      it { expect(data_builder).to be_nil }
    end
  end
end
