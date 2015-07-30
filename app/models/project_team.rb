class ProjectTeam < ActiveRecord::Base


  # ----------------------------------------------------------------------
  # == Include Modules == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Constants == #
  # ----------------------------------------------------------------------

  STATUS = {removed: 0, assigned: 1, re_assigned: 2}


  # ----------------------------------------------------------------------
  # == Attributes == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == File Uploader == #
  # ----------------------------------------------------------------------

  # ----------------------------------------------------------------------
  # == Associations and Nested Attributes == #
  # ----------------------------------------------------------------------

  belongs_to :project
  belongs_to :developer

  # ----------------------------------------------------------------------
  # == Validations == #
  # ----------------------------------------------------------------------

  validates :developer_id, presence: true
  validates :status_date, presence: true
  validates :participation_percentage, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 100}

  # ----------------------------------------------------------------------
  # == Callbacks == #
  # ----------------------------------------------------------------------

  after_create :make_column_archive

  # ----------------------------------------------------------------------
  # == Scopes and Other macros == #
  # ----------------------------------------------------------------------

  scope :with_project, ->(id) { where(:project_id => id) }
  scope :with_developer, ->(id) { where(:developer_id => id) }
  scope :project_recent_data, ->(project_id) { where(project_id: project_id, most_recent_data: true).where.not(status: 0) }
  scope :by_developer_and_date, ->(dev_id, date) { where('developer_id = ? AND status != 0 AND  status_date <= ? AND id IN (?) ', dev_id, date, where('status_date <= ?', date).group(:developer_id, :project_id).maximum(:id).values) }



  # ----------------------------------------------------------------------
  # == Instance methods == #
  # ----------------------------------------------------------------------


  private

  def make_column_archive
    project_teams = ProjectTeam.where(developer_id: self.developer_id, project_id: self.project_id, most_recent_data: true).where('id != ?', self.id)
    if project_teams.present?
      project_teams.each do |project_team|
        project_team.most_recent_data = false
        project_team.save
      end
    end
  end

end
