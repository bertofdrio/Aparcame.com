json.times @booking_times do |booking|
  json.id booking.id
  json.start_time booking.start_time
  json.end_time booking.end_time
  #json.paid booking.paid
end

