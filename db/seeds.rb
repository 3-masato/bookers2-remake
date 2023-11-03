# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

login_user = User.create!(
  email: "login@user",
  name: "momo",
  password: "qwerty"
)

login_user = User.create!(
  email: "test@user",
  name: "aqua",
  password: "qwerty"
)

USER_COUNT = 10
BOOK_COUNT = 5

USER_COUNT.times do |n|
  user = User.create!(
    email: "test#{n + 1}@test.com",
    name: "test user #{n + 1}",
    password: "testhoge"
  )

  BOOK_COUNT.times do |n|
    Book.create!(
      title: "test title #{n + 1}",
      body: "test body #{n + 1}",
      user_id: user.id
    )
  end

  user.follow(login_user)
end
