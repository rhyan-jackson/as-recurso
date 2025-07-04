class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :customer

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true

  def needs_onboarding?
    !customer.nil? && !customer.username.nil?
  end
end
