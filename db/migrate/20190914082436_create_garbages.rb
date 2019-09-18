class CreateGarbages < ActiveRecord::Migration[5.2]
  def change
    create_table :garbages do |t|
      t.string :wday_id
      t.string :first_nth_id
      t.string :second_nth_id
      t.string :garbage_type_id
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
