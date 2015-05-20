class ProjectTeam < ActiveRecord::Base
belongs_to :project
belongs_to :developer

validates :developer_id, presence: true
validates :start_date, presence: true

scope :with_project, ->(id) { where(:project_id => id)}
scope :with_developer, ->(id) { where(:developer_id => id)}

end
