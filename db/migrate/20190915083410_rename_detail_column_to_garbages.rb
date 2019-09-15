class RenameDetailColumnToGarbages < ActiveRecord::Migration[5.2]
  def change
    rename_column :garbages, :garbage_type, :garbage_type_id
    rename_column :garbages, :wday, :wday_id
    rename_column :garbages, :nth, :nth_id
  end
end
