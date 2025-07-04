class Customer < ApplicationRecord
  belongs_to :user
  has_many :payments
  has_many :rides
  has_many :reservations

  validates :username, uniqueness: true
  validates :id_card_number, uniqueness: true

  enum :status, { active: 0, suspended: 1, banned: 2 }

  def resident?
    !id_card_number.nil?
  end

  def active_ride
    rides.active.first
  end

  def has_active_ride?
    active_ride.present?
  end

  def has_reservation?(station)
    active_reservations_at_station(station).exists?
  end

  def active_reservations_at_station(station)
    reservations.pending
              .joins(:bike)
              .where(bikes: { station_id: station.id })
              .where("end_time >= ?", Time.current)
  end

  def get_reservation_at_station(station)
    active_reservations_at_station(station).first
  end
end
