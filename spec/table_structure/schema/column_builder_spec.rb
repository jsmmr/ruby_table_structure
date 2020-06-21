# frozen_string_literal: true

RSpec.describe TableStructure::Schema::ColumnBuilder do
  describe '.create_optional_builders' do
    let(:column_builders) { described_class.create_optional_builders(**options) }

    context 'when :name_prefix is set' do
      let(:options) { { name_prefix: 'prefix_' } }

      it { expect(column_builders).to include(:_name_prepender_) }
      it { expect(column_builders[:_name_prepender_].applicable_to_header?).to be true }
      it { expect(column_builders[:_name_prepender_].applicable_to_body?).to be false }
      it { expect(column_builders[:_name_prepender_].call('value')).to eq 'prefix_value' }
      it { expect(column_builders[:_name_prepender_].call(nil)).to eq nil }
    end

    context 'when :name_prefix is not set' do
      let(:options) { { name_prefix: nil } }
      it { expect(column_builders).not_to include(:_name_prepender_) }
    end

    context 'when :name_suffix is set' do
      let(:options) { { name_suffix: '_suffix' } }
      it { expect(column_builders).to include(:_name_appender_) }
      it { expect(column_builders[:_name_appender_].applicable_to_header?).to be true }
      it { expect(column_builders[:_name_appender_].applicable_to_body?).to be false }
      it { expect(column_builders[:_name_appender_].call('value')).to eq 'value_suffix' }
      it { expect(column_builders[:_name_appender_].call(nil)).to eq nil }
    end

    context 'when :name_suffix is not set' do
      let(:options) { { name_suffix: nil } }
      it { expect(column_builders).not_to include(:_name_appender_) }
    end
  end
end
