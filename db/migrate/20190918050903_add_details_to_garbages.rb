class AddDetailsToGarbages < ActiveRecord::Migration[5.2]
  def change
    add_column :garbages, :second_nth_id, :string
  end
end
