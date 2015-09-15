require 'view_helper.rb'

class UserMailer < ApplicationMailer

  helper ViewHelper

  def booking_time_client_email (booking_time)
    @booking = booking_time.booking
    @carpark = @booking.carpark
    @garage = @carpark.garage
    @booking_time = booking_time

    mail(to: @booking.user.email, subject: I18n.t('emails.booking_charge'))
  end


  def booking_time_owner_email (booking_time)
    @booking = booking_time.booking
    @carpark = @booking.carpark
    @garage = @carpark.garage
    @booking_time = booking_time

    mail(to: @carpark.user.email, subject: I18n.t('emails.booking_profit'))
  end

  def new_booking_email (booking)
    @booking = booking
    @carpark = booking.carpark
    @garage = booking.carpark.garage
    @booking_times = @booking.booking_times

    mail(to: booking.user.email, subject: I18n.t('emails.new_booking'))
  end

  def update_booking_email (booking)
    @booking = booking
    @carpark = booking.carpark
    @garage = booking.carpark.garage
    @booking_times = @booking.booking_times

    mail(to: booking.user.email, subject: I18n.t('emails.update_booking'))
  end

  def delete_booking_email (booking)
    @booking = booking
    @carpark = booking.carpark
    @garage = booking.carpark.garage
    @booking_times = @booking.booking_times

    mail(to: booking.user.email, subject: I18n.t('emails.delete_booking'))
  end

  def gate_task_in_email (booking_time)
    @booking = booking_time.booking
    @carpark = @booking.carpark
    @garage = @booking.carpark.garage
    @booking_time = booking_time

    mail(to: @booking.user.email, subject: I18n.t('emails.booking_info'))
  end

  def gate_task_out_email (booking_time)
    @booking = booking_time.booking
    @carpark = @booking.carpark
    @garage = @booking.carpark.garage
    @booking_time = booking_time

    mail(to: @booking.user.email, subject: I18n.t('emails.booking_ended'))
  end

end
