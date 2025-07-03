class Reservation < ApplicationRecord
  belongs_to :customer

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validate :start_time_in_future, if: -> { start_time.present? }
  validate :end_time_after_start_time
  validate :no_overlapping_pending_reservations

  before_validation :set_default_end_time

  enum :status, { pending: 0, cancelled: 1, expired: 2, used: 3 }

  scope :active, -> { where(status: :pending) }
  scope :future, -> { where("start_time > ?", Time.current) }
  scope :past, -> { where("start_time < ?", Time.current) }

  private
  def start_time_in_future
    if start_time < Time.current
      errors.add(:start_time, "must be in the future")
    end
  end


  def set_default_end_time
    return unless start_time
    if end_time.blank? || end_time <= start_time
      self.end_time = start_time + 15.minutes
    end
  end

  def end_time_after_start_time
    return unless start_time && end_time
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  def no_overlapping_pending_reservations
    return unless customer

    existing = Reservation.pending.where(customer: customer)
    existing = existing.where.not(id: id) if persisted?

    if existing.exists?
      errors.add(:base, "You already have a pending reservation")
    end
  end
end
