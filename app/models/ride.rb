class Ride < ApplicationRecord
  belongs_to :customer
  belongs_to :bike
  belongs_to :origin_station, class_name: "Station"
  belongs_to :destination_station, class_name: "Station", optional: true
  belongs_to :expected_destination_station, class_name: "Station"
  has_many :payments

  validates :start_time, presence: true
  validates :expected_end_time, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(end_time: nil) }
  scope :completed, -> { where.not(end_time: nil) }

  def duration
    return nil unless end_time
    ((end_time - start_time) / 1.minute).round
  end

  def active?
    end_time.nil?
  end
end
