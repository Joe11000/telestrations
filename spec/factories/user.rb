FactoryBot.define do

  factory :user do
    name { "#{Faker::Name.first_name.upcase} #{Faker::Name.first_name.upcase}" }
    sequence(:uid) {|n| n + 1}
    provider { ['twitter', 'facebook'].sample }
    provider_avatar { Rack::Test::UploadedFile.new(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg'), content_type: 'image/jpg') ) }


    trait :twitter do
      provider { 'twitter' }
    end

    trait :facebook do
      provider { 'facebook' }
    end
  end
end
