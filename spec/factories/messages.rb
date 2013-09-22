# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    conversation nil
    user nil
    content "MyText"
  end
end
