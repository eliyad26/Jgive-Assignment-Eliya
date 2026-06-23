class Campaign < ApplicationRecord
  has_many :donations, dependent: :destroy

  validates :title, presence: true
  validates :goal_amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :bonus_goal_amount_cents, numericality: { greater_than: 0 }, allow_nil: true
  validates :currency, presence: true

  def total_raised_cents
    donations.where(status: %w[pending paid]).sum(:amount_cents)
  end

  def donor_count
    donations.where.not(status: :failed).count
  end

  def main_progress_percentage
    return 0 if goal_amount_cents.zero?
    ((total_raised_cents.to_f / goal_amount_cents) * 100).to_i
  end

  def has_bonus_goal?
    bonus_goal_amount_cents.present?
  end

  def display_donations
    donations.where.not(status: :failed).order(created_at: :desc)
  end
end
