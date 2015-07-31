class AddColumnActiveToTableDevelopers < ActiveRecord::Migration
  def change
    add_column :developers, :active, :boolean, default: 1
  end
end
