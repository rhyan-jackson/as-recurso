class StationsController < ApplicationController
  def index
    @stations = Station.includes(:county, :bikes)
    @stations_with_bikes = @stations.joins(:bikes)
                                   .where(bikes: { status: :available })
                                   .distinct

    @stations_json = @stations.map do |station|
      {
        id: station.id,
        name: station.name,
        latitude: station.latitude,
        longitude: station.longitude,
        county: station.county.name,
        available_bikes: station.bikes.available.count,
        max_capacity: station.max_capacity,
        full_location: station.full_location
      }
    end.to_json
  end

  def show
    @station = Station.find(params[:id])
    @free_spots = @station.free_spots
    @available_bikes = @station.bikes.available

    @bike_types = @available_bikes.group_by(&:brand).map do |brand, bikes|
      {
        brand: brand,
        count: bikes.count,
        price: bikes.first.pricing,
        bikes: bikes
      }
    end
  end
end
