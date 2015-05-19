class ChangeJoiningDateFormatInDevelopersTable < ActiveRecord::Migration
  def change
    change_column :developers, :joining_date, :date
  end
end
