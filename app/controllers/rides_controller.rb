class RidesController < ApplicationController
  def start_confirm
    @origin_station = Station.find(params[:origin])
    @destination_station = Station.find(params[:destination]) if params[:destination]
    @brand = params[:brand]
    @reservation = Reservation.find(params[:reservation_id]) if params[:reservation_id]

    # If this is from a reservation pickup, use the reserved bike
    if @reservation
      @bike = @reservation.bike
      @from_reservation = true
    else
      # Find an available bike of the selected brand (normal flow)
      @bike = @origin_station.bikes.available.where(brand: @brand).first
      @from_reservation = false
    end

    if @bike.nil?
      # Handle no bike available
      render :no_bike_available and return
    end

    # If destination not selected yet, redirect to station selection
    unless @destination_station
      redirect_to stations_path(
        mode: "select_destination",
        origin: @origin_station.id,
        brand: @brand,
        reservation_id: @reservation&.id
      )
      return
    end

    # Calculate estimated distance and time
    @distance = @origin_station.distance_to(@destination_station)
    @estimated_time_hours = [ @distance / 15.0, 0.5 ].max # 15km/h speed, min 30 minutes

    # Calculate price - if from reservation, don't charge reservation fee again
    base_ride_price = (@bike.pricing * @estimated_time_hours).round(2)
    @estimated_price = @from_reservation ? base_ride_price : base_ride_price

    # Check if user has sufficient balance
    @sufficient_balance = Current.user&.customer&.balance.to_f >= @estimated_price

    # Render without layout for modal
    render layout: false
  end

  def create
    @origin_station = Station.find(params[:origin])
    @destination_station = Station.find(params[:destination])
    @brand = params[:brand]
    @reservation = Reservation.find(params[:reservation_id]) if params[:reservation_id]

    # If this is from a reservation, use the reserved bike
    if @reservation
      @bike = @reservation.bike
      from_reservation = true
    else
      # Find and reserve the bike (normal flow)
      @bike = @origin_station.bikes.available.where(brand: @brand).first
      from_reservation = false
    end

    if @bike.nil?
      redirect_to stations_path, alert: "Bicicleta não disponível."
      return
    end

    # Calculate price
    distance = @origin_station.distance_to(@destination_station)
    estimated_time_hours = [ distance / 15.0, 0.5 ].max
    price = (@bike.pricing * estimated_time_hours).round(2)
    price = (price < 0.30) ? 0.30 : price # Minimum 30 cents

    # If from reservation, user already paid reservation fee, so only charge ride price
    # You might want to give them credit for the reservation fee or just charge the ride price
    actual_charge = from_reservation ? [ price - (@reservation.price || 0), 0 ].max : price

    # Check balance
    if Current.user.customer.balance < actual_charge
      redirect_to stations_path, alert: "Saldo insuficiente."
      return
    end

    # Create the ride
    @ride = Ride.new(
      customer: Current.user.customer,
      bike: @bike,
      origin_station: @origin_station,
      expected_destination_station: @destination_station,
      start_time: Time.current,
      expected_end_time: Time.current + estimated_time_hours.hours,
      price: price
    )

    if @ride.save
      # Update bike status and customer balance
      @bike.update!(status: :in_use)
      Current.user.customer.update!(balance: Current.user.customer.balance - actual_charge)

      # If this was from a reservation, mark it as used (if not already done)
      @reservation&.update!(status: :used)

      # Render success frame instead of redirecting
      render :start_success, layout: false
    else
      # Render error frame
      @error_message = "Erro ao iniciar viagem: #{@ride.errors.full_messages.join(', ')}"
      render :error, layout: false
    end
  end

  def end_confirm
    @ride = Ride.find(params[:id])
    @destination_station = Station.find(params[:station_id])

    # Calculate actual duration and any additional costs
    @actual_duration_hours = (Time.current - @ride.start_time) / 1.hour
    @additional_cost = [ @actual_duration_hours - (@ride.expected_end_time - @ride.start_time) / 1.hour, 0 ].max * @ride.bike.pricing
    @total_cost = @ride.price + @additional_cost

    render layout: false
  end

  def update
    @ride = Ride.find(params[:id])
    @destination_station = Station.find(ride_params[:destination_station_id])
    @additional_cost = ride_params[:additional_cost].to_f

    # Check if customer has sufficient balance for additional costs
    if @additional_cost > 0 && Current.user.customer.balance < @additional_cost
      @error_message = "Saldo insuficiente para custos adicionais."
      render :error, layout: false
      return
    end

    # Calculate actual distance traveled
    actual_distance = @ride.origin_station.distance_to(@destination_station)

    # End the ride
    @ride.update!(
      destination_station: @destination_station,
      end_time: Time.current
    )

    # Update bike: set as available and move to destination station
    @ride.bike.update!(
      status: :available,
      station: @destination_station,
      total_kms: @ride.bike.total_kms + actual_distance
    )

    # Charge additional costs if any
    if @additional_cost > 0
      Current.user.customer.update!(
        balance: Current.user.customer.balance - @additional_cost
      )
    end

    # Render success frame
    render :end_success, layout: false
  end

  private

  def ride_params
    params.require(:ride).permit(:destination_station_id, :additional_cost)
  end
end
