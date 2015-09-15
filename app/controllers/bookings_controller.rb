class BookingsController < ApplicationController
  before_action :set_booking, only: [:destroy, :edit, :update, :show_booking_times, :hide_booking_times]
  before_filter :authenticate_user!
  before_filter :owner!, only: [:destroy, :edit, :update, :show_booking_times, :hide_booking_times]
  before_filter :can_edit!, only: [:edit, :update]

  # GET /bookings
  # GET /bookings.json
  def index
    @bookings = Booking.where("user_id = ?", current_user.id)
  end

  # GET /bookings/1/edit
  def edit
  end

  # PATCH/PUT /bookings/1
  # PATCH/PUT /bookings/1.json
  def update
    respond_to do |format|
      if @booking.update(booking_params)
        UserMailer.update_booking_email(@booking).deliver_later

        format.html { redirect_to bookings_url, notice: I18n.t('text.general.successfully_updated', name: Booking.model_name.human) }
        format.json { render :show, status: :ok, location: @booking }
      else
        format.html { render :edit }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookings/1
  # DELETE /bookings/1.json
  def destroy
    records_deleted = @booking.delete_booking_times_not_paid
    @booking.destroy

    respond_to do |format|
      if @booking.destroyed?
        #email de borrado de reserva
        UserMailer.delete_booking_email(@booking).deliver_now

        format.html { redirect_to bookings_url, notice: I18n.t('text.general.successfully_destroyed', name: Booking.model_name.human) }
        format.json { head :ok }
      else
        #email de actualización si se ha borrado algo
        UserMailer.update_booking_email(@booking).deliver_later if records_deleted > 0

        format.html { redirect_to bookings_url, notice: @booking.errors.full_messages }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  respond_to :js

  def show_booking_times
    @booking_times = @booking.booking_times

    respond_to do |format|
      format.js
    end
  end

  def hide_booking_times
    @booking_times = nil

    respond_to do |format|
      format.js
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_booking
    @booking = Booking.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def booking_params
    params.require(:booking).permit(:name, :license, :phone, :price, :reduced_price, :references, :references)
  end

  def owner!
    if @booking.user != current_user
      redirect_to(root_url, :notice => I18n.t('text.general.unauthorized'))
    end
  end

  def can_edit!
    redirect_to(bookings_url, :notice => I18n.t('text.booking.cannot_edit')) if @booking.booking_times.already_paid.count > 0
  end
end
