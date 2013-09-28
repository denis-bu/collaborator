# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:nickname) { |n| "Nickname #{n}" }
    password "Password_123$"
    password_confirmation { "#{password}" }
  end
end
