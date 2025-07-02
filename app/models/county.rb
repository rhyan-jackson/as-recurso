class County < ApplicationRecord
  has_many :stations
  has_many :county_providers
  has_many :providers, through: :county_providers
  has_many :county_admins

  validates :name, presence: true
  validates :latitude, presence: true, numericality: { in: -90.0..90.0 }
  validates :longitude, presence: true, numericality: { in: -180.0..180.0 }

  def coordinates
    [ latitude, longitude ]
  end

  def location_name
    "#{name} (#{latitude}, #{longitude})"
  end
end
