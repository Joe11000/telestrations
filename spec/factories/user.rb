FactoryBot.define do
  factory :user do
    name { "#{Faker::Name.first_name.upcase} #{Faker::Name.first_name.upcase}" }
    provider { rand(2) == 0 ? 'twitter' : 'facebook' }
    uid { rand(1000..100000) }
  end
end
