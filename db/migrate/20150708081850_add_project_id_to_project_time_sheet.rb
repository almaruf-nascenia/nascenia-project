class AddProjectIdToProjectTimeSheet < ActiveRecord::Migration
  def change
    add_column :project_time_sheets, :project_id, :integer
  end
end
