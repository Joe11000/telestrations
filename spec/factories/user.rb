FactoryBot.define do

  factory :user do
    sequence(:email) {|n| "email_#{n}@aol.com"}
    sequence(:password_digest) {|n| "password_#{n}"}
  end
end
