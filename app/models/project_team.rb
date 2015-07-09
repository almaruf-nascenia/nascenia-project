class ProjectTeam < ActiveRecord::Base
belongs_to :project
belongs_to :developer

validates :developer_id, presence: true
validates :start_date, presence: true
validates :participation_percentage, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 100}

scope :with_project, ->(id) { where(:project_id => id)}
scope :with_developer, ->(id) { where(:developer_id => id)}

end
