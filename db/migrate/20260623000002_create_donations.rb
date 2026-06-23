class CreateDonations < ActiveRecord::Migration[7.1]
  def change
    create_table :donations do |t|
      t.references :campaign,          null: false, foreign_key: true
      t.string     :donor_name,        null: false
      t.integer    :amount_cents,      null: false
      t.string     :currency,          null: false, default: "ILS"
      t.string     :frequency,         null: false, default: "one_time"
      t.string     :display_preference, null: false, default: "full_name"
      t.text       :dedication
      t.string     :status,            null: false, default: "pending"

      t.timestamps
    end

    add_index :donations, :status
  end
end
