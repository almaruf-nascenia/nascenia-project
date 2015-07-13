class Developer < ActiveRecord::Base

  # ----------------------------------------------------------------------
  # == Include Modules == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Constants == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Attributes == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == File Uploader == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Associations and Nested Attributes == #
  # ----------------------------------------------------------------------

  has_many :project_teams, dependent: :destroy
  has_many :projects, through: :project_teams

  has_many :active_project_teams, -> { where(most_recent_data: true).where.not(status: 0) }, class_name: 'ProjectTeam'
  has_many :active_developer_project, -> { where status: true }, class_name: 'ProjectTeam'


  # ----------------------------------------------------------------------
  # == Validations == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Callbacks == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Scopes and Other macros == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Instance methods == #
  # ----------------------------------------------------------------------

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

  def company_tenure
      (((Date.today - self.joining_date) / 365).to_f).round(2)
  end

  def total_experience
    (self.company_tenure + self.previous_job_exp).round(2)
  end

  def active_project

  end
end
