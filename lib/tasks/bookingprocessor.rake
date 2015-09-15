#encoding: UTF-8
namespace :process do
  desc 'Process all not paid booking_times'
  task :bookings => :environment do
    puts 'Process bookings'

    puts Booking.first.name
  end

  desc 'Process all not sent SMS to gate´s devices'
  task :gate_tasks => :bookings do
    puts 'Process gate_tasks'
  end
end
