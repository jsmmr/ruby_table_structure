# frozen_string_literal: true

RSpec.describe TableStructure::Schema do
  describe '#contain_callable?' do
    let(:attribute) { 'attribute' }

    subject { schema.new.contain_callable?(attribute) }

    context 'when callables are contained' do
      let(:schema) do
        ::TableStructure::Schema.create_class do
          column name: 'a', key: :a, value: ->(*) { 1 }
          column name: ->(*) { 'b' }, key: :b, value: 2
        end
      end

      context 'attribute: name' do
        let(:attribute) { :name }
        it { is_expected.to be true }
      end

      context 'attribute: value' do
        let(:attribute) { :value }
        it { is_expected.to be true }
      end
    end

    context 'when callables are not contained' do
      let(:schema) do
        ::TableStructure::Schema.create_class do
          column name: 'a', key: :a, value: '1'
          column name: 'b', key: :b, value: '2'
        end
      end

      context 'attribute: name' do
        let(:attribute) { :name }
        it { is_expected.to be false }
      end

      context 'attribute: value' do
        let(:attribute) { :value }
        it { is_expected.to be false }
      end
    end
  end
end
