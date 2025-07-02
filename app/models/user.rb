class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :customer

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def needs_onboarding?
    !customer || !customer.username
  end
end
