class Donation < ApplicationRecord
  belongs_to :campaign

  enum :frequency, { one_time: "one_time", monthly: "monthly" }, default: "one_time"
  enum :display_preference, { full_name: "full_name", first_name: "first_name", anonymous: "anonymous" }, default: "full_name"
  enum :status, { pending: "pending", paid: "paid", failed: "failed" }, default: "pending"

  validates :donor_name, presence: true
  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true

  def displayed_name
    case display_preference
    when "full_name"  then donor_name
    when "first_name" then donor_name.split.first
    when "anonymous"  then "תורם אנונימי"
    end
  end
end
