class CreateCampaigns < ActiveRecord::Migration[8.1]
  def change
    create_table :campaigns do |t|
      t.string  :title,                  null: false
      t.string  :slogan
      t.text    :story
      t.string  :cover_image_url
      t.string  :video_url
      t.integer :goal_amount_cents,       null: false
      t.integer :bonus_goal_amount_cents
      t.string  :currency,               null: false, default: "ILS"

      t.timestamps
    end
  end
end
