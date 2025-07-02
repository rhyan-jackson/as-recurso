class CountyProvider < ApplicationRecord
  belongs_to :county
  belongs_to :provider

  # A provider can only be added once per county
  validates :provider_id, uniqueness: { scope: :county_id }
end
