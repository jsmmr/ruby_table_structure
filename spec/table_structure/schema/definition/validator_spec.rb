# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Definition::Validator do
  let(:validator) { described_class.new(name, index) }
  let(:name) { 'TestTableSchema' }
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

    describe '.new' do
      it 'raises error' do
        expect { validator.validate(attrs) }
          .to raise_error '"key" must not be lambda. [TestTableSchema] defined position of column(s): 1'
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

    describe '.new' do
      it 'raises error' do
        expect { validator.validate(attrs) }
          .to raise_error '"size" must be defined, because column size cannot be determined. [TestTableSchema] defined position of column(s): 1'
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

    describe '.new' do
      it 'raises error' do
        expect { validator.validate(attrs) }
          .to raise_error '"size" must be positive. [TestTableSchema] defined position of column(s): 1'
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

    describe '.new' do
      it 'raises error' do
        expect { validator.validate(attrs) }
          .to raise_error '"key" size must not be less than specified "size". [TestTableSchema] defined position of column(s): 1'
      end
    end
  end
end
