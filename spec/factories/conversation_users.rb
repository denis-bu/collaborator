# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :conversation_user do
    conversation nil
    user nil
  end
end
