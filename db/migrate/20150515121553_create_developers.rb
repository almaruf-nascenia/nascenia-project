class CreateDevelopers < ActiveRecord::Migration
  def change
    create_table :developers do |t|
      t.string :name
      t.string :designation
      t.datetime :joining_date
      t.float :previous_job_exp

      t.timestamps
    end
  end
end
