class RemoveEndDateAndRenameStartDateFromProjectTeams < ActiveRecord::Migration
  def change
    remove_column :project_teams, :end_date
    rename_column :project_teams, :start_date, :status_date
    add_column :project_teams, :most_recent_data, :boolean, default: true
  end
end
