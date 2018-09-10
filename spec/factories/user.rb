FactoryBot.define do

  factory :user do
    name { "#{Faker::Name.first_name.upcase} #{Faker::Name.first_name.upcase}" }
    sequence(:uid) {|n| n + 1}
    provider { rand(2) == 0 ? 'twitter' : 'facebook' }
    provider_avatar { "http://joe-noonan-101.herokuapp.com/assets/formal_me/1-00e70838635a49004071492dcfe4e154600e684f8f3e81899ac265286c7fd685.jpg" }


    trait :twitter do
      provider { 'twitter' }
    end

    trait :facebook do
      provider { 'facebook' }
    end
  end
end
