FactoryGirl.define do
  factory :transaction do
    association :user
    movement_type 0
    amount 10
    token "UNIQUETOKEN"

    factory :withdraw do
      movement_type 1
      status "Pending"
      token nil
    end
  end
end