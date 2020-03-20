# frozen_string_literal: true

RSpec.shared_context 'questions' do
  let(:questions) do
    [
      { id: 'Q1', text: 'Do you like sushi?' },
      { id: 'Q2', text: 'Do you like yakiniku?' },
      { id: 'Q3', text: 'Do you like ramen?' }
    ]
  end
end

RSpec.shared_context 'users' do
  let(:users) do
    [
      {
        id: 1,
        name: '太郎',
        pets: %w[cat dog],
        answers: { 'Q1' => 'yes', 'Q2' => 'no', 'Q3' => 'yes' }
      },
      {
        id: 2,
        name: '花子',
        pets: %w[rabbit turtle squirrel giraffe],
        answers: { 'Q1' => 'yes', 'Q2' => 'yes', 'Q3' => 'no' }
      },
      {
        id: 3,
        name: '次郎',
        pets: %w[tiger elephant doragon],
        answers: { 'Q1' => 'no', 'Q2' => 'yes', 'Q999' => 'yes' }
      }
    ]
  end

  let(:nested_users) do
    [
      users[0].merge(partner: users[1]),
      users[1].merge(partner: users[0]),
      users[2].merge(partner: nil)
    ]
  end
end

RSpec.shared_context 'table_structured_array' do
  let(:header_row) do
    [
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

  let(:body_row_taro) do
    [
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

  let(:body_row_hanako) do
    [
      2,
      '花子',
      'rabbit',
      'turtle',
      'squirrel',
      'yes',
      'yes',
      'no'
    ]
  end

  let(:body_row_jiro) do
    [
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

RSpec.shared_context 'table_structured_hash' do
  let(:header_row) do
    {
      id: 'ID',
      name: 'Name',
      pet1: 'Pet 1',
      pet2: 'Pet 2',
      pet3: 'Pet 3',
      q1: 'Q1',
      q2: 'Q2',
      q3: 'Q3'
    }
  end

  let(:body_row_taro) do
    {
      id: 1,
      name: '太郎',
      pet1: 'cat',
      pet2: 'dog',
      pet3: nil,
      q1: 'yes',
      q2: 'no',
      q3: 'yes'
    }
  end

  let(:body_row_hanako) do
    {
      id: 2,
      name: '花子',
      pet1: 'rabbit',
      pet2: 'turtle',
      pet3: 'squirrel',
      q1: 'yes',
      q2: 'yes',
      q3: 'no'
    }
  end

  let(:body_row_jiro) do
    {
      id: 3,
      name: '次郎',
      pet1: 'tiger',
      pet2: 'elephant',
      pet3: 'doragon',
      q1: 'no',
      q2: 'yes',
      q3: nil
    }
  end
end
