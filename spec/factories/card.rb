FactoryGirl.define do

  factory :card do

    factory :drawing do
      drawing_file_name { Faker::Avatar.image }
    end

    factory :description do
      description_text { Faker::Lorem.sentence(3)}
    end

  end
end
