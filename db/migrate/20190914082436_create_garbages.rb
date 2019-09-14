class CreateGarbages < ActiveRecord::Migration[5.2]
  def change
    create_table :garbages do |t|
      t.string :wday
      t.string :nth
      t.string :type
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
