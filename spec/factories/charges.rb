# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :charge do
    paid_at DateTime.now
    association :booking_time, :factory => :booking_time_with_availability
  end
end
