class HistoryController < ApplicationController
  before_action :load_customer

  def index
    @history_items = build_history_items
    @payments_count = @customer.payments.count
    @rides_count = @customer.rides.completed.count
    @reservations_count = @customer.reservations.count
  end

  private

  def load_customer
    @customer = Current.user.customer
    redirect_to onboarding_path(:username) if @customer.nil?
  end

  def build_history_items
    items = []

    # Add payments
    @customer.payments.includes(:customer).order(created_at: :desc).each do |payment|
      items << {
        type: "payment",
        timestamp: payment.created_at,
        data: payment,
        formatted_time: format_timestamp(payment.created_at),
        title: "Carregamento +#{format_currency(payment.amount)}",
        subtitle: payment_method_name(payment.method),
        amount: "+#{format_currency(payment.amount)}",
        status: "success"
      }
    end

    # Add completed rides
    @customer.rides.completed.includes(:origin_station, :destination_station, :bike)
             .order(end_time: :desc).each do |ride|
      items << {
        type: "ride",
        timestamp: ride.end_time,
        data: ride,
        formatted_time: format_ride_time(ride),
        title: "#{ride.origin_station.name} → #{ride.destination_station&.name || ride.expected_destination_station.name}",
        subtitle: "#{ride.duration} min • Bicicleta ##{ride.bike.id}",
        amount: "-#{format_currency(ride.price)}",
        status: "completed"
      }
    end

    # Add all reservations
    @customer.reservations.includes(:bike).order(created_at: :desc).each do |reservation|
      items << {
        type: "reservation",
        timestamp: reservation.created_at,
        data: reservation,
        formatted_time: format_timestamp(reservation.created_at),
        title: "Reserva na #{reservation.bike.station.name}",
        subtitle: "Bicicleta ##{reservation.bike.id} • #{reservation_duration(reservation)} min",
        amount: reservation_amount_display(reservation),
        status: reservation.status
      }
    end

    # Sort all items by timestamp (most recent first)
    items.sort_by { |item| item[:timestamp] }.reverse
  end

  def format_timestamp(timestamp)
    timestamp.strftime("%d/%m/%Y às %H:%M")
  end

  def format_ride_time(ride)
    return format_timestamp(ride.end_time) unless ride.start_time && ride.end_time

    if ride.start_time.to_date == ride.end_time.to_date
      "#{ride.start_time.strftime('%H:%M')} → #{ride.end_time.strftime('%H:%M')}"
    else
      "#{ride.start_time.strftime('%d/%m às %H:%M')} → #{ride.end_time.strftime('%d/%m às %H:%M')}"
    end
  end

  def format_currency(amount)
    ActionController::Base.helpers.number_with_precision(amount, precision: 2, delimiter: " ")
  end

  def payment_method_name(method)
    case method
    when "mbway"
      "MBWay"
    when "revolut"
      "Revolut"
    else
      method.titleize
    end
  end

  def reservation_duration(reservation)
    ((reservation.end_time - reservation.start_time) / 1.minute).round
  end

  def reservation_amount_display(reservation)
    case reservation.status
    when "cancelled"
      "+#{reservation.price}"
    when "used"
      ""
    else
      "-#{reservation.price}"
    end
  end
end
