class AddStartDateToProjectTeams < ActiveRecord::Migration
  def change
    add_column :project_teams, :start_date, :date
    add_column :project_teams, :end_date, :date
  end
end
