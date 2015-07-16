class AddColumnPreviousParticipationToProjectTeams < ActiveRecord::Migration
  def change
    add_column :project_teams, :previous_participation_percentage, :integer, default: 0
  end
end
