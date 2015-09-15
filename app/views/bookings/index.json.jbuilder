json.array!(@bookings) do |booking|
  json.extract! booking, :id, :name, :license, :phone, :price, :reduced_price, :references, :references
  json.url booking_url(booking, format: :json)
end
