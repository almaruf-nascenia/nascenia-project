class AddStatusToProjectTeams < ActiveRecord::Migration
  def change
    add_column :project_teams, :status, :boolean, :default => false
  end
end
