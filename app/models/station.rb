class Station < ApplicationRecord
  belongs_to :county
  has_many :bikes
  has_many :origin_rides, class_name: "Ride", foreign_key: "origin_station_id"
  has_many :destination_rides, class_name: "Ride", foreign_key: "destination_station_id"
  has_many :expected_destination_rides, class_name: "Ride", foreign_key: "expected_destination_station_id"

  validates :name, presence: true
  validates :latitude, presence: true, numericality: { in: -90.0..90.0 }
  validates :longitude, presence: true, numericality: { in: -180.0..180.0 }
  validates :max_capacity, numericality: { greater_than: 0 }

  def coordinates
    [ latitude, longitude ]
  end

  def full_location
    "#{name} - #{county.name} (#{latitude}, #{longitude})"
  end

  def distance_to(other_station)
    return 0 if self == other_station

    lat1_rad = latitude * Math::PI / 180
    lat2_rad = other_station.latitude * Math::PI / 180
    delta_lat = (other_station.latitude - latitude) * Math::PI / 180
    delta_lon = (other_station.longitude - longitude) * Math::PI / 180

    a = Math.sin(delta_lat / 2) * Math.sin(delta_lat / 2) +
        Math.cos(lat1_rad) * Math.cos(lat2_rad) *
        Math.sin(delta_lon / 2) * Math.sin(delta_lon / 2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    earth_radius_kms = 6371
    earth_radius_kms * c
  end
end
