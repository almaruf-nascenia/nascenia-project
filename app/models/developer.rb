class Developer < ActiveRecord::Base
  has_many :project_teams, dependent: :destroy
  has_many :projects, through: :project_teams

  has_many :active_developer_project, -> { where status: true }, class_name: 'ProjectTeam'

  validates :name, presence: true
  validates :designation, presence: true
  validates :joining_date, presence: true

  def project_participation(project_id)
    project = self.project_teams.where('project_id = ? and status = true', project_id).first
    project.present? ? project.participation_percentage: 0
  end

  def assign_team(project_id)
    self.project_teams.where('project_id = ?', project_id).first
  end

  def all_without(project_id)
    where("id NOT IN (?)", project_id)
  end

end
