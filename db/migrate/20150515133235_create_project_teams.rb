class CreateProjectTeams < ActiveRecord::Migration
  def change
    create_table :project_teams do |t|
      t.integer :project__id
      t.integer :developer_id
      t.float :participation_percentage

      t.timestamps
    end
  end
end
