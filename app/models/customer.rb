class Customer < ApplicationRecord
  belongs_to :user
  has_many :payments
  has_many :rides
  has_many :reservations

  validates :username, presence: true, uniqueness: true
  validate :only_one_active_ride_per_customer

  enum :status, { active: 0, suspended: 1, banned: 2 }

  def active_ride
    rides.active.first
  end

  def has_active_ride?
    active_ride.present?
  end


  private

  def only_one_active_ride_per_customer
    return unless customer && end_time.nil?

    existing_active = customer.rides.active.where.not(id: id)
    if existing_active.exists?
      errors.add(:base, "Já tem uma viagem ativa")
    end
  end
end
