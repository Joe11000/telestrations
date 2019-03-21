FactoryBot.define do

  factory :user do
    sequence(:email) {|n| "email_#{n}@aol.com"}
    password { email }
  end
end
