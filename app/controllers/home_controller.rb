class HomeController < ApplicationController

  # GET /homes
  # GET /homes.json
  def index
    if !current_user.nil?
      @booking_times = BookingTime.joins(:booking).where(:bookings => {:user_id => current_user.id}).next().limit(5)
    end
  end

  # GET /home/description
  def description
  end

  # GET /home/contact
  def contact
  end

  # GET /home/faq
  def faq
  end

end
