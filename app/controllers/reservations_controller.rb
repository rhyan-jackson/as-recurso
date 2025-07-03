class ReservationsController < ApplicationController
  before_action :set_reservation, only: [ :show, :cancel ]

def new
  @station = Station.find(params[:station_id])
  @brand = params[:brand]
  @available_bikes = @station.bikes.available
  if @brand.present?
    @available_bikes = @available_bikes.where(brand: @brand)
  end
  if @available_bikes.empty?
    @error_message = "Não há bicicletas #{@brand} disponíveis nesta estação."
    render :no_bikes_available, layout: false and return
  end

  @bike = @available_bikes.first
  @reservation = Reservation.new

  # Generate available times
  today = Date.current
  @available_hours = []

  if Rails.env.development?
    # In development, show times for the next 24 hours
    current_hour = Time.current.hour
    ((current_hour)..(current_hour + 24)).each do |hour|
      actual_hour = hour % 24  # Handle wrap around after 23
      [0, 15, 30, 45].each do |minutes|
        time = today.beginning_of_day + actual_hour.hours + minutes.minutes
        # Adjust day if we wrapped around
        time += 1.day if hour >= 24
        
        next if time <= Time.current

        @available_hours << {
          value: time.strftime("%Y-%m-%dT%H:%M"),
          display: time.strftime("%H:%M"),
          time: time
        }
      end
    end
  else
    # In production, keep the original 8-19 restriction
    (8..19).each do |hour|
      [0, 15, 30, 45].each do |minutes|
        time = today.beginning_of_day + hour.hours + minutes.minutes
        next if time <= Time.current

        @available_hours << {
          value: time.strftime("%Y-%m-%dT%H:%M"),
          display: time.strftime("%H:%M"),
          time: time
        }
      end
    end
  end

  render layout: false
end

  def create
    @station = Station.find(params[:station_id])
    @brand = params[:reservation][:brand]

    @bike = @station.bikes.available.where(brand: @brand).first

    if @bike.nil?
      redirect_to stations_path, alert: "Bicicleta não disponível."
      return
    end

    start_time = DateTime.parse(params[:reservation][:start_time])
    base_price = 2.0 # Base reservation fee

    @reservation = Reservation.new(
      customer: Current.user.customer,
      start_time: start_time,
      end_time: start_time + 15.minutes, # 15 minute pickup window
      price: base_price,
      bike: @bike
    )

    if @reservation.save
      # Don't change bike status yet - it stays available until pickup
      # Deduct reservation fee from balance
      Current.user.customer.update!(
        balance: Current.user.customer.balance - base_price
      )
      @bike.reserved!

      render :success, layout: false
    else
      @error_message = "Erro ao criar reserva: #{@reservation.errors.full_messages.join(', ')}"
      render :error, layout: false
    end
  end

  def show
    render layout: false
  end

  def cancel
    # Cancel reservation by updating status
    if @reservation.pending? && @reservation.start_time > Time.current
      @reservation.update!(status: :cancelled)
      @reservation.bike.update!(status: :available)

      # Refund the reservation fee
      Current.user.customer.update!(
        balance: Current.user.customer.balance + @reservation.price
      )

      redirect_to root_path, notice: "Reserva cancelada com sucesso. Valor reembolsado."
    elsif @reservation.cancelled?
      redirect_to root_path, alert: "Esta reserva já foi cancelada."
    else
      redirect_to root_path, alert: "Não é possível cancelar esta reserva."
    end
  end

  def pickup
    @reservation = Reservation.find(params[:id])
    @station = @reservation.bike.station

    # Verify the reservation is valid for pickup (can pick up early, but not after expiry)
    unless @reservation.pending? && @reservation.end_time >= Time.current
      redirect_to @station, alert: "Esta reserva não está disponível para levantamento."
      return
    end

    # Verify the bike is still at the station and reserved
    unless @reservation.bike.reserved? && @reservation.bike.station == @station
      redirect_to @station, alert: "A bicicleta reservada não está disponível."
      return
    end

    # Mark reservation as used
    @reservation.update!(status: :used)

    # Redirect to stations map in destination selection mode
    redirect_to stations_path(
      mode: "select_destination",
      origin: @station.id,
      brand: @reservation.bike.brand,
      reservation_id: @reservation.id
    ), notice: "Reserva levantada com sucesso! Selecione o destino da sua viagem."
  end

  private

  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  def reservation_params
    params.require(:reservation).permit(:start_time)
  end
end
