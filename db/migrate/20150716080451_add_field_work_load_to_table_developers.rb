class AddFieldWorkLoadToTableDevelopers < ActiveRecord::Migration
  def change
    add_column :developers, :work_load, :integer, default: 0
  end
end
