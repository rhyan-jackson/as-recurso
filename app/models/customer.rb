class Customer < ApplicationRecord
  belongs_to :user

  enum :status, { active: 0, suspended: 1, banned: 2 }
end
