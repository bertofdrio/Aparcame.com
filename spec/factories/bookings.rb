FactoryGirl.define do
  factory :booking do
    name "General"
    license '1111-AAA'
    # phone { rand(1**9..9**9)}
    sequence(:phone) { |n| "123456789#{n}" }
    price 0.7
    reduced_price 0.35
    association :carpark
    association :user

    factory :booking_next_month do
      association :carpark, :factory => :carpark_owner

      after(:build) do |booking|
        date = (Date.today + 1.month).beginning_of_month

        # reserva para menos de una semana
        booking.booking_times  << FactoryGirl.build(:booking_time,
                                                  start_time: date + 9.hours,
                                                  end_time: date + 16.hours - Availability::MINIMUN_MINUTES_SEGMENT.minutes,
                                                  booking: booking)

        booking.booking_times  << FactoryGirl.build(:booking_time,
                                                    start_time: date + 6.days + 9.hours,
                                                    end_time: date + 6.days + 16.hours - Availability::MINIMUN_MINUTES_SEGMENT.minutes,
                                                    booking: booking)

        booking.booking_times  << FactoryGirl.build(:booking_time,
                                                    start_time: date + 2.weeks + 9.hours,
                                                    end_time: date + 2.weeks + 16.hours - Availability::MINIMUN_MINUTES_SEGMENT.minutes,
                                                    booking: booking)
      end
    end

    factory :invalid_booking do
      license nil
      phone nil
    end
  end
end
