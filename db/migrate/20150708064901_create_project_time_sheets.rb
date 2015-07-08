class CreateProjectTimeSheets < ActiveRecord::Migration
  def change
    create_table :project_time_sheets do |t|
      t.string :Title
      t.string :Description
      t.string :Link

      t.timestamps
    end
  end
end
