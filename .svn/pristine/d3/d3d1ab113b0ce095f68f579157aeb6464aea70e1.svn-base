FactoryGirl.define do
  factory :carpark do
    description 'Plaza 1'
    sequence(:number, 10000) {|n| "#{n}" }
    price 0.7
    reduced_price 0.35
    profit 0.25
    association :user
    association :garage

    factory :carpark_owner do
      after(:build) do |carpark|
        carpark.rents  << FactoryGirl.build(:rent_next_month, carpark: carpark)
      end
    end

    factory :carpark_few_availabilities do
      after(:build) do |carpark|
        carpark.rents  << FactoryGirl.build(:rent_few_availabilities, carpark: carpark)
      end
    end
  end
end


