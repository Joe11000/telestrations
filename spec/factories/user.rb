FactoryBot.define do

  factory :user do
    name { "#{Faker::Name.first_name.upcase} #{Faker::Name.first_name.upcase}" }
    sequence(:uid) {|n| n + 1}
    provider { ['twitter', 'facebook'].sample }

    after(:build) do |user|
      user.provider_avatar.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg'), \
       ), content_type: 'image/jpg', filename: 'provider_avatar.jpg')
    end

    trait :twitter do
      provider { 'twitter' }
    end

    trait :facebook do
      provider { 'facebook' }
    end
  end
end
