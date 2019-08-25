# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Definition::Validator do
  let(:validator) { described_class.new(index, options) }
  let(:index) { 0 }

  context 'when key is lambda' do
    let(:attrs) do
      {
        name: nil,
        key: -> { nil },
        value: nil,
        size: nil
      }
    end

    let(:options) { {} }

    describe '.new' do
      it 'raises error' do
        expect { validator.validate(attrs) }
          .to raise_error '"key" must not be lambda. [defined position of column(s): 1]'
      end
    end
  end

  context 'when column size cannot be determined' do
    let(:attrs) do
      {
        name: ->(*) { 'Name' },
        key: nil,
        value: nil,
        size: nil
      }
    end

    let(:options) { {} }

    describe '.new' do
      it 'raises error' do
        expect { validator.validate(attrs) }
          .to raise_error '"size" must be defined, because column size cannot be determined. [defined position of column(s): 1]'
      end
    end
  end

  context 'when column size is negative' do
    let(:attrs) do
      {
        name: nil,
        key: nil,
        value: nil,
        size: 0
      }
    end

    let(:options) { {} }

    describe '.new' do
      it 'raises error' do
        expect { validator.validate(attrs) }
          .to raise_error '"size" must be positive. [defined position of column(s): 1]'
      end
    end
  end

  context 'when key is not present with "result_type: :hash"' do
    let(:attrs) do
      {
        name: nil,
        key: nil,
        value: nil,
        size: nil
      }
    end

    let(:options) { { result_type: :hash } }

    describe '.new' do
      it 'raises error' do
        expect { validator.validate(attrs) }
          .to raise_error '"key" must be defined when "result_type: :hash" is specified. [defined position of column(s): 1]'
      end
    end
  end

  context 'When both key and size are specified and key\'s size is not enough' do
    let(:attrs) do
      {
        name: 'Name',
        key: :name,
        value: nil,
        size: 2
      }
    end

    let(:options) { {} }

    describe '.new' do
      it 'raises error' do
        expect { validator.validate(attrs) }
          .to raise_error '"key" size must be greater than or equal to specified "size". [defined position of column(s): 1]'
      end
    end
  end
end
