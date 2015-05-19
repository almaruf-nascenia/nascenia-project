class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :project_teams, :project__id, :project_id
  end
end
