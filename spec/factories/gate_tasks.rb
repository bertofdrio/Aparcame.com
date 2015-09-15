# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :gate_task do
    association :booking_time, :factory => :booking_time_with_availability
    user_phone '123456789'
    garage_phone '123456789'
    action :in
    time DateTime.now
  end
end
