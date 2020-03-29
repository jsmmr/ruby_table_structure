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
