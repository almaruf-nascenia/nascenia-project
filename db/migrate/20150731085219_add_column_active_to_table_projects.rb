class AddColumnActiveToTableProjects < ActiveRecord::Migration
  def change
    add_column :projects, :active, :boolean, default: 1
  end
end
