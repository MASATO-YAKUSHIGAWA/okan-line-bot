class RenameTypeColumnToGarbages < ActiveRecord::Migration[5.2]
  def change
    rename_column :garbages, :type, :garbage_type
  end
end
