#encoding: utf-8

FactoryGirl.define do
  factory :booking_time do
    sequence(:start_time, 100) {|n| Date.today + n.week + 7.hours }
    sequence(:end_time, 100) {|n| Date.today + n.week + 9.hours }
    paid false
    association :booking

    factory :booking_time_with_availability do
      after(:build) do |booking_time|
        rent = build(:rent, carpark: booking_time.booking.carpark)
        rent.availabilities << build(:availability,
                                    start_time: booking_time.start_time - 2.hours,
                                    end_time: booking_time.end_time + 2.hours)
        rent.save
      end
    end

    factory :booking_time_with_availability_next_month do
      date = (Date.today + 1.month).beginning_of_month

      after(:build) do |booking_time|
        booking_time.start_time = date + 7.hours
        booking_time.end_time = date + 9.hours

        rent = build(:rent, carpark: booking_time.booking.carpark)
        rent.availabilities << build(:availability,
                                     start_time: booking_time.start_time - 2.hours,
                                     end_time: booking_time.end_time + 2.hours)
        rent.save
      end
    end
  end
end


