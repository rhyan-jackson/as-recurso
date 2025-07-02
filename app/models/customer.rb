class Customer < ApplicationRecord
  belongs_to :user
  has_many :payments
  has_many :rides
  has_many :reservations

  enum :status, { active: 0, suspended: 1, banned: 2 }
end
