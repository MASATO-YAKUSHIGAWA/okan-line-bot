class RenameNthIdColumnToGarbages < ActiveRecord::Migration[5.2]
  def change
    rename_column :garbages, :nth_id, :first_nth_id
  end
end
