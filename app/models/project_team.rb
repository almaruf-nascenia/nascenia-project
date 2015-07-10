class ProjectTeam < ActiveRecord::Base
belongs_to :project
belongs_to :developer

validates :developer_id, presence: true
validates :status_date, presence: true
validates :participation_percentage, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 100}

scope :with_project, ->(id) { where(:project_id => id)}
scope :with_developer, ->(id) { where(:developer_id => id)}

def self.make_column_archive(dev_id, project_id, latest_column_id)
  project_team = ProjectTeam.where(developer_id: dev_id, project_id: project_id, most_recent_data: true).where('id != ?', latest_column_id).first
  if project_team.present?
    project_team.most_recent_data = false
    project_team.save
  end
end

end
