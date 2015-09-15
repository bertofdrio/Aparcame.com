class BookingTimesController < ApplicationController
  before_action :set_booking_time, only: [:destroy]
  before_filter :authenticate_user!, :get_booking, :owner!

  # DELETE /bookings/1/booking_times/1
  # DELETE /bookings/1/booking_times/1.json
  def destroy
    @booking_time.destroy
    respond_to do |format|
      if @booking_time.destroyed?
        #email de borrado
        format.html { redirect_to bookings_url, notice: I18n.t('text.general.successfully_destroyed', name: BookingTime.model_name.human) }
        format.json { head :no_content }
      else
        format.html { redirect_to bookings_url, notice: @booking_time.errors.full_message }
        format.json { render json: @booking_time.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking_time
      @booking_time = BookingTime.find(params[:id])
    end

  def get_booking
    @booking = Booking.find params[:booking_id]
  end

  def owner!
    if @booking.user != current_user
      redirect_to(root_url, :notice => I18n.t('text.general.unauthorized'))
    end
  end

end
