# frozen_string_literal: true

RSpec.describe TableStructure::Iterator do
  describe '#iterate' do
    include_context 'questions'
    include_context 'users'

    let(:context) { { questions: questions } }
    let(:items) { users }

    context 'options validation' do
      subject do
        described_class.new(
          ::Mono::TestTableSchema.new(context: context),
          **header_options
        )
      end

      context 'when header step is not numeric' do
        let(:header_options) do
          { header: { step: 'a' } }
        end

        it 'raises error' do
          expect { subject }
            .to raise_error ':step must be numeric.'
        end
      end

      context 'when header step is negative' do
        let(:header_options) do
          { header: { step: 0 } }
        end

        it 'raises error' do
          expect { subject }
            .to raise_error ':step must be positive number.'
        end
      end
    end

    context 'when :row_type is :array' do
      include_context 'table_structured_array'

      let(:iterator) do
        described_class.new(
          ::Mono::TestTableSchema.new(context: context),
          **header_options,
          row_type: :array
        )
      end

      context 'when :header is set true' do
        let(:header_options) do
          [
            { header: true },
            { header: { context: {} } },
            { header: { step: nil } },
            {}
          ].sample
        end

        describe '#map' do
          subject { iterator.iterate(items).map(&:itself) }
          it 'returns rows as array with header' do
            expect(subject.size).to eq 4
            expect(subject[0]).to eq header_row
            expect(subject[1]).to eq body_row_taro
            expect(subject[2]).to eq body_row_hanako
            expect(subject[3]).to eq body_row_jiro
          end

          context 'with positive step' do
            let(:header_options) do
              { header: { step: 2 } }
            end

            it 'returns rows as array with header' do
              expect(subject.size).to eq 5
              expect(subject[0]).to eq header_row
              expect(subject[1]).to eq body_row_taro
              expect(subject[2]).to eq body_row_hanako
              expect(subject[3]).to eq header_row
              expect(subject[4]).to eq body_row_jiro
            end
          end
        end

        describe '#take' do
          subject { iterator.iterate(items).lazy.take(1).force }
          it 'returns rows as array with header' do
            expect(subject.size).to eq 1
            expect(subject[0]).to eq header_row
          end
        end
      end

      context 'when :header is set false' do
        let(:header_options) do
          { header: false }
        end

        describe '#map' do
          subject { iterator.iterate(items).map(&:itself) }
          it 'returns rows as array without header' do
            expect(subject.size).to eq 3
            expect(subject[0]).to eq body_row_taro
            expect(subject[1]).to eq body_row_hanako
            expect(subject[2]).to eq body_row_jiro
          end
        end

        describe '#take' do
          subject { iterator.iterate(items).lazy.take(1).force }
          it 'returns rows as array without header' do
            expect(subject.size).to eq 1
            expect(subject[0]).to eq body_row_taro
          end
        end
      end
    end

    context 'when :row_type is :hash' do
      include_context 'table_structured_hash'

      let(:iterator) do
        described_class.new(
          ::Mono::WithKeys::TestTableSchema.new(context: context),
          **header_options,
          row_type: :hash
        )
      end

      context 'when :header is set true' do
        let(:header_options) do
          [
            { header: true },
            { header: { context: {} } },
            { header: { step: nil } },
            {}
          ].sample
        end

        describe '#map' do
          subject { iterator.iterate(items).map(&:itself) }
          it 'returns rows as hash with header' do
            expect(subject.size).to eq 4
            expect(subject[0]).to eq header_row
            expect(subject[1]).to eq body_row_taro
            expect(subject[2]).to eq body_row_hanako
            expect(subject[3]).to eq body_row_jiro
          end

          context 'with positive step' do
            let(:header_options) do
              { header: { step: 2 } }
            end

            it 'returns rows as hash with header' do
              expect(subject.size).to eq 5
              expect(subject[0]).to eq header_row
              expect(subject[1]).to eq body_row_taro
              expect(subject[2]).to eq body_row_hanako
              expect(subject[3]).to eq header_row
              expect(subject[4]).to eq body_row_jiro
            end
          end
        end

        describe '#take' do
          subject { iterator.iterate(items).lazy.take(1).force }
          it 'returns rows as hash with header' do
            expect(subject.size).to eq 1
            expect(subject[0]).to eq header_row
          end
        end
      end

      context 'when :header is set false' do
        let(:header_options) do
          { header: false }
        end

        describe '#map' do
          subject { iterator.iterate(items).map(&:itself) }
          it 'returns rows as hash without header' do
            expect(subject.size).to eq 3
            expect(subject[0]).to eq body_row_taro
            expect(subject[1]).to eq body_row_hanako
            expect(subject[2]).to eq body_row_jiro
          end
        end

        describe '#take' do
          subject { iterator.iterate(items).lazy.take(1).force }
          it 'returns rows as hash without header' do
            expect(subject.size).to eq 1
            expect(subject[0]).to eq body_row_taro
          end
        end
      end
    end
  end
end
