# frozen_string_literal: true

RSpec.describe TableStructure::Schema do
  include_context 'questions'

  describe '.create_class' do
    subject { ::TableStructure::Schema.create_class(&block) }

    context 'when block has been given' do
      let(:block) { proc { column name: 'ID', value: 1 } }
      it { is_expected.to be_a ::Class }
    end

    context 'when no block has been given' do
      let(:block) { nil }
      it { expect { subject }.to raise_error 'No block has been given.' }
    end
  end

  describe '.+' do
    subject { ::Mono::TestTableSchema + schema_class }

    context 'valid' do
      let(:schema_class) { ::Mono::TestTableSchema }
      it { is_expected.to be_a ::Class }
    end

    context 'invalid' do
      let(:schema_class) { 'foo' }
      it { expect { subject }.to raise_error 'Must be a schema class. [foo]' }
    end
  end

  describe '.merge' do
    subject { ::Mono::TestTableSchema.merge(schema_class) }

    context 'valid' do
      let(:schema_class) { ::Mono::TestTableSchema }
      it { is_expected.to be_a ::Class }
    end

    context 'invalid' do
      let(:schema_class) { 'foo' }
      it { expect { subject }.to raise_error 'Must be a schema class. [foo]' }
    end
  end

  describe '#columns_keys' do
    subject { schema.columns_keys }

    let(:schema) do
      ::Mono::WithKeys::TestTableSchema.new(context: { questions: questions })
    end

    it { is_expected.to eq %i[id name pet1 pet2 pet3 q1 q2 q3] }
  end

  describe '#columns_size' do
    subject { schema.columns_size }

    let(:schema) do
      ::Mono::TestTableSchema.new(context: { questions: questions })
    end

    it { is_expected.to eq 8 }
  end

  describe '#contain_name_callable?' do
    subject { schema.contain_name_callable? }

    context 'when callables are contained' do
      let(:schema) do
        schema_class = ::TableStructure::Schema.create_class do
          column name: 'a', key: :a, value: ->(*) { 1 }
          column name: ->(*) { 'b' }, key: :b, value: 2
        end
        schema_class.new
      end

      subject { schema.contain_name_callable? }
      it { is_expected.to be true }
    end

    context 'when callables are not contained' do
      let(:schema) do
        schema_class = ::TableStructure::Schema.create_class do
          column name: 'a', key: :a, value: '1'
          column name: 'b', key: :b, value: '2'
        end
        schema_class.new
      end

      subject { schema.contain_name_callable? }
      it { is_expected.to be false }
    end
  end

  describe '#contain_value_callable?' do
    subject { schema.contain_value_callable? }

    context 'when callables are contained' do
      let(:schema) do
        schema_class = ::TableStructure::Schema.create_class do
          column name: 'a', key: :a, value: ->(*) { 1 }
          column name: ->(*) { 'b' }, key: :b, value: 2
        end
        schema_class.new
      end

      subject { schema.contain_value_callable? }
      it { is_expected.to be true }
    end

    context 'when callables are not contained' do
      let(:schema) do
        schema_class = ::TableStructure::Schema.create_class do
          column name: 'a', key: :a, value: '1'
          column name: 'b', key: :b, value: '2'
        end
        schema_class.new
      end

      subject { schema.contain_value_callable? }
      it { is_expected.to be false }
    end
  end

  describe '#create_header_row_generator' do
    let(:row) { schema.create_header_row_generator.call(context) }

    let(:schema) do
      ::Mono::WithKeys::TestTableSchema.new(context: { questions: questions })
    end

    let(:context) { { foo: :bar } }

    it { expect(row.keys).to eq %i[id name pet1 pet2 pet3 q1 q2 q3] }
    it { expect(row.values).to eq ['ID', 'Name', 'Pet 1', 'Pet 2', 'Pet 3', 'Q1', 'Q2', 'Q3'] }
    it { expect(row.context).to eq context }
  end

  describe '#create_data_row_generator' do
    include_context 'users'

    let(:row) { schema.create_data_row_generator.call(context) }

    let(:schema) do
      ::Mono::WithKeys::TestTableSchema.new(context: { questions: questions })
    end

    let(:context) { users.first }

    it { expect(row.keys).to eq %i[id name pet1 pet2 pet3 q1 q2 q3] }
    it { expect(row.values).to eq [1, '太郎', 'cat', 'dog', nil, 'yes', 'no', 'yes'] }
    it { expect(row.context).to eq context }
  end
end
