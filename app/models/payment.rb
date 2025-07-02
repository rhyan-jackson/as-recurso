class Payment < ApplicationRecord
  belongs_to :customer

  enum :method, { mbway: 0, revolut: 1 }

  validates :amount, numericality: { greater_than: 0 }
end
