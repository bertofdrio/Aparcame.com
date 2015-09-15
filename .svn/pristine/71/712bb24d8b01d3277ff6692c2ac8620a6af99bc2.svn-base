FactoryGirl.define do
  factory :garage do
    name 'Garage Central'
    address 'C/Uria'
    city 'Oviedo'
    # phone { rand(1**9..9**9)}
    sequence(:phone) { |n| "123456789#{n}" }
    postal_code '33010'
    latitude 5.0
    longitude 5.0
    province Province.find_by_name('Asturias')
  end
end


