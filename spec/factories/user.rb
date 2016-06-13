FactoryGirl.define do
  factory :user do
    name { "#{Faker::Name.first_name.upcase} #{Faker::Name.first_name.upcase}" }
    provider { rand(2) == 0 ? 'twitter' : 'facebook' }
    uid { rand(1000..100000)}

    factory :user_w_uploaded_photo do
      provider_avatar_override_file_name { Faker::Avatar.image }
    end
  end
end
