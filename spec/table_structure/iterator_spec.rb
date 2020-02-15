# frozen_string_literal: true

RSpec.describe TableStructure::Iterator do
  describe '#iterate' do
    include_context 'questions'
    include_context 'users'

    let(:context) { { questions: questions } }
    let(:items) { users }

    context 'when :result_type is :array' do
      let(:row_type_option) { [{ result_type: :array }, { row_type: :array }].sample }

      shared_examples 'to iterate converted data' do
        context 'when :header_omitted is false' do
          let(:header_option) { { header_omitted: false } }

          describe '#map' do
            subject { iterator.iterate(items).map(&:itself) }
            it 'returns rows as array with header' do
              expect(subject.size).to eq 4

              expect(subject[0]).to eq [
                'ID',
                'Name',
                'Pet 1',
                'Pet 2',
                'Pet 3',
                'Q1',
                'Q2',
                'Q3'
              ]

              expect(subject[1]).to eq [
                1,
                '太郎',
                'cat',
                'dog',
                nil,
                'yes',
                'no',
                'yes'
              ]

              expect(subject[2]).to eq [
                2,
                '花子',
                'rabbit',
                'turtle',
                'squirrel',
                'yes',
                'yes',
                'no'
              ]

              expect(subject[3]).to eq [
                3,
                '次郎',
                'tiger',
                'elephant',
                'doragon',
                'no',
                'yes',
                nil
              ]
            end
          end

          describe '#take' do
            subject { iterator.iterate(items).take(1) }
            it 'returns rows as array with header' do
              expect(subject.size).to eq 1

              expect(subject[0]).to eq [
                'ID',
                'Name',
                'Pet 1',
                'Pet 2',
                'Pet 3',
                'Q1',
                'Q2',
                'Q3'
              ]
            end
          end
        end

        context 'when :header_omitted is true' do
          let(:header_option) { { header_omitted: true } }

          describe '#map' do
            subject { iterator.iterate(items).map(&:itself) }
            it 'returns rows as array without header' do
              expect(subject.size).to eq 3

              expect(subject[0]).to eq [
                1,
                '太郎',
                'cat',
                'dog',
                nil,
                'yes',
                'no',
                'yes'
              ]

              expect(subject[1]).to eq [
                2,
                '花子',
                'rabbit',
                'turtle',
                'squirrel',
                'yes',
                'yes',
                'no'
              ]

              expect(subject[2]).to eq [
                3,
                '次郎',
                'tiger',
                'elephant',
                'doragon',
                'no',
                'yes',
                nil
              ]
            end
          end

          describe '#take' do
            subject { iterator.iterate(items).take(1) }
            it 'returns rows as array without header' do
              expect(subject.size).to eq 1

              expect(subject[0]).to eq [
                1,
                '太郎',
                'cat',
                'dog',
                nil,
                'yes',
                'no',
                'yes'
              ]
            end
          end
        end
      end

      context 'deprecated' do
        let(:schema_options) { row_type_option }
        let(:writer_options) { header_option }

        context 'when Schema is specified' do
          let(:iterator) { described_class.new(schema_or_writer, **writer_options) }
          let(:schema_or_writer) { ::Mono::TestTableSchema.new(context: context, **schema_options) }
          it_behaves_like 'to iterate converted data'
        end

        context 'when Writer is specified' do
          let(:iterator) { described_class.new(schema_or_writer) }
          let(:schema_or_writer) do
            schema = ::Mono::TestTableSchema.new(context: context, **schema_options)
            TableStructure::Writer.new(schema, **writer_options)
          end
          it_behaves_like 'to iterate converted data'
        end
      end

      context 'recommend' do
        let(:writer_options) { row_type_option.merge(header_option) }

        context 'when Schema is specified' do
          let(:iterator) { described_class.new(schema_or_writer, **writer_options) }
          let(:schema_or_writer) { ::Mono::TestTableSchema.new(context: context) }
          it_behaves_like 'to iterate converted data'
        end

        context 'when Writer is specified' do
          let(:iterator) { described_class.new(schema_or_writer) }
          let(:schema_or_writer) do
            schema = ::Mono::TestTableSchema.new(context: context)
            TableStructure::Writer.new(schema, **writer_options)
          end
          it_behaves_like 'to iterate converted data'
        end
      end
    end

    context 'when :result_type is :hash' do
      let(:row_type_option) { [{ result_type: :hash }, { row_type: :hash }].sample }

      shared_examples 'to iterate converted data' do
        context 'when :header_omitted is false' do
          let(:header_option) { { header_omitted: false } }

          describe '#map' do
            subject { iterator.iterate(items).map(&:itself) }
            it 'returns rows as hash with header' do
              expect(subject.size).to eq 4

              expect(subject[0]).to eq(
                id: 'ID',
                name: 'Name',
                pet1: 'Pet 1',
                pet2: 'Pet 2',
                pet3: 'Pet 3',
                q1: 'Q1',
                q2: 'Q2',
                q3: 'Q3'
              )

              expect(subject[1]).to eq(
                id: 1,
                name: '太郎',
                pet1: 'cat',
                pet2: 'dog',
                pet3: nil,
                q1: 'yes',
                q2: 'no',
                q3: 'yes'
              )

              expect(subject[2]).to eq(
                id: 2,
                name: '花子',
                pet1: 'rabbit',
                pet2: 'turtle',
                pet3: 'squirrel',
                q1: 'yes',
                q2: 'yes',
                q3: 'no'
              )

              expect(subject[3]).to eq(
                id: 3,
                name: '次郎',
                pet1: 'tiger',
                pet2: 'elephant',
                pet3: 'doragon',
                q1: 'no',
                q2: 'yes',
                q3: nil
              )
            end
          end

          describe '#take' do
            subject { iterator.iterate(items).take(1) }
            it 'returns rows as hash with header' do
              expect(subject.size).to eq 1

              expect(subject[0]).to eq(
                id: 'ID',
                name: 'Name',
                pet1: 'Pet 1',
                pet2: 'Pet 2',
                pet3: 'Pet 3',
                q1: 'Q1',
                q2: 'Q2',
                q3: 'Q3'
              )
            end
          end
        end

        context 'when :header_omitted is true' do
          let(:header_option) { { header_omitted: true } }

          describe '#map' do
            subject { iterator.iterate(items).map(&:itself) }
            it 'returns rows as hash without header' do
              expect(subject.size).to eq 3

              expect(subject[0]).to eq(
                id: 1,
                name: '太郎',
                pet1: 'cat',
                pet2: 'dog',
                pet3: nil,
                q1: 'yes',
                q2: 'no',
                q3: 'yes'
              )

              expect(subject[1]).to eq(
                id: 2,
                name: '花子',
                pet1: 'rabbit',
                pet2: 'turtle',
                pet3: 'squirrel',
                q1: 'yes',
                q2: 'yes',
                q3: 'no'
              )

              expect(subject[2]).to eq(
                id: 3,
                name: '次郎',
                pet1: 'tiger',
                pet2: 'elephant',
                pet3: 'doragon',
                q1: 'no',
                q2: 'yes',
                q3: nil
              )
            end
          end

          describe '#take' do
            subject { iterator.iterate(items).take(1) }
            it 'returns rows as hash without header' do
              expect(subject.size).to eq 1

              expect(subject[0]).to eq(
                id: 1,
                name: '太郎',
                pet1: 'cat',
                pet2: 'dog',
                pet3: nil,
                q1: 'yes',
                q2: 'no',
                q3: 'yes'
              )
            end
          end
        end
      end

      context 'deprecated' do
        let(:schema_options) { row_type_option }
        let(:writer_options) { header_option }

        context 'when Schema is specified' do
          let(:iterator) { described_class.new(schema_or_writer, **writer_options) }
          let(:schema_or_writer) { ::Mono::WithKeys::TestTableSchema.new(context: context, **schema_options) }
          it_behaves_like 'to iterate converted data'
        end

        context 'when Writer is specified' do
          let(:iterator) { described_class.new(schema_or_writer) }
          let(:schema_or_writer) do
            schema = ::Mono::WithKeys::TestTableSchema.new(context: context, **schema_options)
            TableStructure::Writer.new(schema, **writer_options)
          end
          it_behaves_like 'to iterate converted data'
        end
      end

      context 'recommend' do
        let(:writer_options) { row_type_option.merge(header_option) }

        context 'when Schema is specified' do
          let(:iterator) { described_class.new(schema_or_writer, **writer_options) }
          let(:schema_or_writer) { ::Mono::WithKeys::TestTableSchema.new(context: context) }
          it_behaves_like 'to iterate converted data'
        end

        context 'when Writer is specified' do
          let(:iterator) { described_class.new(schema_or_writer) }
          let(:schema_or_writer) do
            schema = ::Mono::WithKeys::TestTableSchema.new(context: context)
            TableStructure::Writer.new(schema, **writer_options)
          end
          it_behaves_like 'to iterate converted data'
        end
      end
    end
  end
end
