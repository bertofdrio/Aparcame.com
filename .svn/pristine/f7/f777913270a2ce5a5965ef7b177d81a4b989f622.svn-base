class RentsController < ApplicationController
  before_filter :authenticate_user!, :get_carpark, :owner!
  before_action :set_rent, only: [:destroy, :show, :edit, :update]

  # GET /rents
  # GET /rents.xml
  def index
    @rents = @carpark.rents

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rents }
    end
  end

  # GET /rents/1
  # GET /rents/1.xml
  def show
    respond_to do |format|
      format.html
      format.xml  { render :xml => @rent }
    end
  end

  # GET /rents/new
  # GET /rents/new.xml
  def new
    @rent = @carpark.rents.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rent }
    end
  end

  # POST /rents
  # POST /rents.xml
  def create
    @rent = @carpark.rents.build(name: rent_params[:name])

    respond_to do |format|
      if @rent.save
        format.html { redirect_to carpark_rent_path(@carpark, @rent), notice: I18n.t('text.general.successfully_created', name: Rent.model_name.human) }
        format.xml  { render :xml => @rent, :status => :created, :location => @rent }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @rent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /rents/1/edit
  def edit
  end

  # PUT /rents/1
  # PUT /rents/1.xml
  def update
    respond_to do |format|
      if @rent.update_attributes(params[:rent])
        format.html { redirect_to(@rent, :notice => I18n.t('text.general.successfully_updated', name: Rent.model_name.human)) }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @rent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rents/1
  # DELETE /rents/1.xml
  def destroy
    @rent.delete_availabilities_without_booking
    @rent.destroy

    respond_to do |format|
      if @rent.destroyed?
        format.html { redirect_to carpark_rents_url, notice: I18n.t('text.general.successfully_destroyed', name: Rent.model_name.human) }
        format.json { head :ok }
      else
        format.html { redirect_to carpark_rent_path(@carpark, @rent), notice: @rent.errors.full_messages }
        format.json { render json: @rent.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_rent
    @rent = @carpark.rents.find(params[:id])
  end

  def get_carpark
    @carpark = Carpark.find params[:carpark_id]
  end

  def owner!
    if @carpark.user != current_user
      redirect_to(root_url, :notice => I18n.t('text.general.unauthorized'))
    end
  end

  def rent_params
    params.require(:rent).permit(:name)
  end
end

