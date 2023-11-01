FactoryBot.define do
  factory :book_comment do
    user
    book
    comment { Faker::Lorem.characters(number: 20) }
  end
end
