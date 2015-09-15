FactoryGirl.define do
  factory :rent do
    sequence(:name, 100) {|n| "General#{n}" }
    association :carpark

    # after(:build) do |rent|
    #   rent.availabilities  << FactoryGirl.build(:availability, rent: rent)
    # end

    factory :rent_next_month do
      after(:build) do |rent|
        date = (Date.today + 1.month).beginning_of_month
        day_end_of_the_month = (Date.today + 1.month).end_of_month.mday

        (0..day_end_of_the_month).each do |day|
          rent.availabilities  << FactoryGirl.build(:availability,
                                                    start_time: date + day.day + 8.hours,
                                                    end_time: date + day.day + 17.hours - Availability::MINIMUN_MINUTES_SEGMENT.minutes,
                                                    rent: rent)
        end
      end
    end

    factory :rent_few_availabilities do
      after(:build) do |rent|
        date = (Date.today + 1.month).beginning_of_month
        day_end_of_the_month = (Date.today + 1.month).end_of_month.mday

        (0..2).each do |day|
          rent.availabilities  << FactoryGirl.build(:availability,
                                                    start_time: date + day.day + 8.hours,
                                                    end_time: date + day.day + 17.hours - Availability::MINIMUN_MINUTES_SEGMENT.minutes,
                                                    rent: rent)
        end
      end
    end

  end
end