# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def new_booking_email
    UserMailer.new_booking_email(Booking.last)
  end

  def update_booking_email
    UserMailer.update_booking_email(Booking.last)
  end

  def delete_booking_email
    UserMailer.delete_booking_email(Booking.last)
  end

  def delete_booking_time_email
    UserMailer.delete_booking_time_email(Booking.last.booking_times.first)
  end

  def booking_time_client_email
    UserMailer.booking_time_client_email(Booking.last.booking_times.first)
  end

  def booking_time_owner_email
    UserMailer.booking_time_owner_email(Booking.last.booking_times.first)
  end

  def gate_task_in_email
    UserMailer.gate_task_in_email(Booking.last.booking_times.first)
  end

  def gate_task_out_email
    UserMailer.gate_task_out_email(Booking.last.booking_times.first)
  end
end
