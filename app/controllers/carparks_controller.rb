class CarparksController < ApplicationController
  before_action :set_carpark, only: [:show, :calendar, :update, :update_bookings, :clear, :clear_month]
  before_filter :authenticate_user!
  before_filter :owner!, only: [:update, :clear, :clear_month]
  before_filter :not_owner!, only: [:update_bookings]

  # GET /carparks
  # GET /carparks.json
  def index
    @carparks = Carpark.where("user_id = ?", current_user.id).order(:garage_id)
  end


  # GET /carparks/1
  # GET /carparks/1.json
  def show
  end

  # PATCH/PUT /carparks/1
  # PATCH/PUT /carparks/1.json
  def update
    respond_to do |format|
      if @carpark.update_attributes(carpark_params)
        format.html { redirect_to(@carpark, :notice => I18n.t('text.general.successfully_updated', :name => Carpark.model_name.human)) }
        format.xml { head :ok }
        format.js { }
      else
        format.html { render }
        format.xml { render :xml => @carpark.errors, :status => :unprocessable_entity }
        format.js { render :status => :unprocessable_entity }
        #:text => @carpark.errors.full_messages,
      end
    end
  end

  # PATCH/PUT /carparks/1/update_bookings
  # PATCH/PUT /carparks/1/update_bookings.json
  def update_bookings
    respond_to do |format|
      if @carpark.update_attributes(carpark_udpate_bookings_params)
        format.html { redirect_to(@carpark, :notice => I18n.t('text.general.successfully_updated', :name => Carpark.model_name.human)) }
        format.xml { head :ok }
        format.js { render :text => I18n.t('text.general.ok') }
      else
        format.html { render }
        format.xml { render :xml => @carpark.errors, :status => :unprocessable_entity }
        format.js { render :update, :status => :unprocessable_entity }
        #:text => @carpark.errors.full_messages,
      end
    end
  end

  respond_to :json

  def calendar
    respond_to do |format|
      if @carpark.user == current_user
        format.html
      else
        format.html { render :calendar_bookings }
      end
    end
  end

  def get_availabilities
    date = params[:date] ? params[:date].to_datetime : DateTime.now

    @availabilities = Availability.joins(:rent).where(:rents => {:carpark_id => params[:id]})
    @availabilities = @availabilities.in_same_month(date)
  end

  def get_bookings
    date = params[:date] ? params[:date].to_datetime : DateTime.now
    user_id = params[:user_id]
    not_user_id = params[:not_user_id]
    paid = params[:paid]

    @booking_times = BookingTime.joins(:booking).where(:bookings => {:carpark_id => params[:id]})
    @booking_times = @booking_times.in_same_month(date)
    @booking_times = @booking_times.where(:bookings => {:user_id => user_id}) unless user_id.blank?
    @booking_times = @booking_times.where(:booking_times => {:paid => paid}) unless paid.blank?
    @booking_times = @booking_times.where("bookings.user_id <> ?", not_user_id) unless not_user_id.blank?
  end

  respond_to :js

  # DELETE /carparks/1/clear.js
  def clear
    @carpark.rents.each { |rent| rent.availabilities.all.destroy_all }
    render :nothing => true
  end

  # DELETE /carparks/1/clear_month.js
  def clear_month
    date = params[:date] ? params[:date].to_datetime : DateTime.now
    @carpark.rents.each { |rent| rent.availabilities.in_same_month(date).destroy_all }
    render :nothing => true
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_carpark
    @carpark = Carpark.find(params[:id])
  end

  def carpark_params
    params.require(:carpark).permit(:id,
                                    rents_attributes: [:id, availabilities_attributes: [:start_time, :end_time]])
  end

  def owner!
    if @carpark.user != current_user
      redirect_to(root_url, :notice => I18n.t('text.general.unauthorized'))
    end
  end

  def carpark_udpate_bookings_params
    params.require(:carpark).permit(:id,
                                    bookings_attributes: [:user_id, :name, :license, :phone, booking_times_attributes: [:start_time, :end_time]])
  end

  def not_owner!
    if @carpark.user == current_user
      if request.xhr? # an AJAX request
        #render(:update) { |page| page.redirect_to(root_url) }
        redirect_to(root_url, :notice => I18n.t('text.general.unauthorized'))
      else
        redirect_to(root_url, :notice => I18n.t('text.general.unauthorized'))
      end
    end
  end
end
