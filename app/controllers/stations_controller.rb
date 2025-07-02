class StationsController < ApplicationController
  def index
    @stations = Station.includes(:county, :bikes)
    @stations_with_bikes = @stations.joins(:bikes)
                                   .where(bikes: { status: :available })
                                   .distinct
  end

  def show
    @station = Station.find(params[:id])
    @available_bikes = @station.bikes.available
    @bikes_by_brand = @available_bikes.group_by(&:brand)
    @total_available = @available_bikes.count
  end
end
