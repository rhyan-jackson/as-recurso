class Station < ApplicationRecord
  belongs_to :county
  has_many :bikes
  has_many :origin_rides, class_name: "Ride", foreign_key: "origin_station_id"
  has_many :destination_rides, class_name: "Ride", foreign_key: "destination_station_id"
  has_many :expected_destination_rides, class_name: "Ride", foreign_key: "expected_destination_station_id"

  validates :name, presence: true
  validates :latitude, presence: true, numericality: { in: -90.0..90.0 }
  validates :longitude, presence: true, numericality: { in: -180.0..180.0 }

  def coordinates
    [ latitude, longitude ]
  end

  def full_location
    "#{name} - #{county.name} (#{latitude}, #{longitude})"
  end
end
