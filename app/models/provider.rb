class Provider < ApplicationRecord
  has_many :county_providers
  has_many :counties, through: :county_providers
  has_many :provider_admins

  validates :name, presence: true

  def operating_counties
    counties.pluck(:name).join(", ")
  end

  def total_stations
    counties.joins(:stations).count
  end
end
