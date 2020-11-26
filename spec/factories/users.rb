FactoryBot.define do
  factory :user do
    name  { Faker::Name.name }
    email { Faker::Internet.email }
    password { User.digest('password') }
  end
end
