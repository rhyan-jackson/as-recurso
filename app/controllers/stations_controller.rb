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

    @reservation_id = params[:reservation_id] if params[:reservation_id]
    # Pass active ride to enable ending it
    @active_ride = Current.user&.customer&.rides&.active&.first

    @active_ride_json =  @active_ride ? {
      id: @active_ride.id,
      bike_brand: @active_ride.bike.brand,
      bike_id: @active_ride.bike.id,
      origin_station_id: @active_ride.origin_station.id,
      origin_station_name: @active_ride.origin_station.name,
      expected_destination_name: @active_ride.expected_destination_station.name,
      start_time: @active_ride.start_time.iso8601,
      price: @active_ride.price
    }.to_json : {}
  end

  def show
    @station = Station.find(params[:id])
    @free_spots = @station.free_spots
    @available_bikes = @station.bikes.available

    # Check for active reservation at this station
    @reservation = Current.user.customer&.get_reservation_at_station(@station)
    @reserved_bike = @reservation&.bike

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
