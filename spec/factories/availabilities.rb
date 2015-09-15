#encoding: utf-8

FactoryGirl.define do
  factory :availability do
    start_time Date.today + 1.week + 5.hours
    end_time Date.today + 1.week + 15.hours
    association :rent
  end
end


