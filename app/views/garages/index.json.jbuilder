json.array!(@garages) do |garage|
  json.extract! garage, :id, :name, :addres, :city, :province_id, :phone, :postal_code
  json.url garage_url(garage, format: :json)
end
