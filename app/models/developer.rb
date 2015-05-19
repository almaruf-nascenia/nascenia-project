class Developer < ActiveRecord::Base
  has_many :project_teams
  has_many :projects, through: :project_teams
  def project_participation(project_id)
    project = self.project_teams.where('project_id = ? and status = true', project_id).first
    project.present? ? project.participation_percentage: 0
  end

  def assign_team(project_id)
    self.project_teams.where('project_id = ?', project_id).first
  end

end
