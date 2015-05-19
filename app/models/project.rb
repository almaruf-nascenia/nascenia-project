class Project < ActiveRecord::Base
has_many :project_teams
has_many :developers, through: :project_teams

default_scope { order("priority ASC") }

  def show_current_team
    ProjectTeam.where('status = true and project_id = ?', self.id)
  end
end
