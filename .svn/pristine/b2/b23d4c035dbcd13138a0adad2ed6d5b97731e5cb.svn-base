class GaragesController < ApplicationController
  before_action :set_garage, only: [:show]
  before_filter :authenticate_user!, :except => [:index]

  # GET /garages
  # GET /garages.json
  def index
    @lat = @lng = 0
    unless params[:search_address].blank?
      search_coordinates = Geocoder.search(params[:search_address])
    end

    unless search_coordinates.blank?
      coordinates = search_coordinates.first

      @garages = Garage.all

      # Comprobamos que la búsqueda tenga dimensiones
      unless coordinates.geometry["bounds"].blank?
        @lat1 = coordinates.geometry["bounds"]["northeast"]["lat"]
        @lng1 = coordinates.geometry["bounds"]["northeast"]["lng"]
        @lat2 = coordinates.geometry["bounds"]["southwest"]["lat"]
        @lng2 = coordinates.geometry["bounds"]["southwest"]["lng"]

        # Recogemos las direcciones alternativas devueltas por la búsqueda
        @alternate_addresses = search_coordinates.collect do |c|
          street = c.address_components.first["long_name"]
          city = c.address_components.second["long_name"]
          "#{street}, #{city}"
        end

        @search_address = @alternate_addresses.first
        # Eliminamos la primera dirección porque es la que usamos para la búsqueda
        @alternate_addresses.delete_at(0)

        @lat = coordinates.geometry["location"]["lat"]
        @lng = coordinates.geometry["location"]["lng"]

        @has_garages = Garage.between(@lat1,@lng1,@lat2,@lng2)
        # @map_options = { "bounds" => "[{\"lat\": #{lat1}, \"lng\": #{lng1} }, {\"lat\": #{lat2} , \"lng\": #{lng2} }]" }
      end
    else
      @garages = Garage.all
    end

    @hash = Gmaps4rails.build_markers(@garages) do |garage, marker|
      marker.lat garage.latitude
      marker.lng garage.longitude
      marker.infowindow garage_infowindow(garage)
      marker.picture garage_marker_picture(garage)
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def garage_infowindow(garage)
    info_window = "#{garage.name} <br/> #{garage.address} <br/> " + I18n.t('text.general.carparks') + ": #{garage.carparks.count} <br/> <a href='#{garage_path(garage)}'>"
    if user_signed_in? == true
      info_window += "#{I18n.t('text.general.show')}</a>"
    end

    return info_window
  end

  def garage_marker_picture(garage)
    {
        "url" => view_context.image_path('custom_marker.png'),
        "width" => 32,
        "height" => 40,
        "marker_anchor" => [ 32, 40],
    }
  end

  # GET /garages/1
  # GET /garages/1.json
  def show
    @garage = Garage.find(params[:id])
    @your_carparks = @garage.carparks.where('carparks.user_id = ?', current_user.id)
    @other_carparks = @garage.carparks.where('carparks.user_id <> ?', current_user.id)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @garage }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_garage
      @garage = Garage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def garage_params
      params.require(:garage).permit(:name, :address, :city, :province_id, :phone, :postal_code)
    end
end
