# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Definition::Validator do
  let(:validator) { described_class.new(index) }
  let(:index) { 0 }

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
          .to raise_error '"size" must be specified, because column size cannot be determined. [defined position of column(s): 1]'
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
          .to raise_error '"size" must be positive. [defined position of column(s): 1]'
      end
    end
  end
end
