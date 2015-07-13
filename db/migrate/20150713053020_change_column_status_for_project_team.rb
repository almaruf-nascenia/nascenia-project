class ChangeColumnStatusForProjectTeam < ActiveRecord::Migration
  def change
    change_column :project_teams, :status, :integer, default: 1
  end
end
