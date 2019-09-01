# frozen_string_literal: true

RSpec.describe TableStructure::Schema::Indexer do
  let(:indexer) { described_class.new }

  it 'returns next values' do
    expect(indexer.next_values).to eq [0]
    expect(indexer.next_values).to eq [1]
    expect(indexer.next_values(size: 1)).to eq [2]
    expect(indexer.next_values(size: 2)).to eq [3, 4]
    expect(indexer.next_values(size: 3)).to eq [5, 6, 7]
  end
end
