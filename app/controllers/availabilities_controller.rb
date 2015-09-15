class AvailabilitiesController < ApplicationController
  before_filter :authenticate_user!, :get_carpark, :get_rent, :owner!
  before_action :set_availability, only: [:destroy]

  # DELETE /carparks/1/rents/1/availabilities/1
  # DELETE /carparks/1/rents/1/availabilities/1.json
  def destroy
    @availability.destroy
    respond_to do |format|
      format.html { redirect_to carpark_rent_path(@carpark, @rent), notice: I18n.t('text.general.successfully_destroyed', name: Availability.model_name.human) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_availability
      @availability = Availability.find(params[:id])
    end

  def get_carpark
    @carpark = Carpark.find params[:carpark_id]
  end

  def get_rent
    @rent = Rent.find params[:rent_id]
  end

  def owner!
    if @carpark.user != current_user
      redirect_to(root_url, :notice => I18n.t('text.general.unauthorized'))
    end
  end


end
