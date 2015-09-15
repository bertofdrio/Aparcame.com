FactoryGirl.define do
  factory :user do
    sequence(:email, 100000) {|n| "user1#{n}@aparcame.com" }
    password 'alberto1'
    confirmed_at Time.now
    balance 100

    # after(:build) do |user|
    #   user.carparks << FactoryGirl.build(:carpark, user: user)
    # end

    factory :not_confirmed_user do
      confirmed_at nil
    end

    factory :owner do
      email 'owner@aparcame.com'
      after(:build) do |user|
        user.carparks << FactoryGirl.build(:carpark_owner, user: user)
      end
    end

    factory :client do
      email 'client@aparcame.com'
      # after(:build) do |user|
      #   user.bookings << FactoryGirl.build(:booking_next_month, user: user)
      # end
    end



  end
end
