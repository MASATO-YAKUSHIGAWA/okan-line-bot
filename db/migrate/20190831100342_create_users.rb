class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :line_id, null: false
      t.references :area_info, null: false, foreign_key: true
      
      t.timestamps
    end
  end
end
