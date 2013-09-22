class AddClassroomIdToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :classroom_id, :integer
    remove_column :assignments, :user_id, :integer
    rename_table :assignments, :classroom_chapters
  end
end