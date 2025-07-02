class Bike < ApplicationRecord
  belongs_to :station
  has_many :rides
  has_many :status_updates

  validates :brand, presence: true
  validates :total_kms, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :pricing, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true

  enum :status, { available: 0, in_use: 1, maintenance: 2, charging: 3, lost: 4, stolen: 5, reserved: 6 }
end
