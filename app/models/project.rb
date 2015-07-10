class Project < ActiveRecord::Base
has_many :project_teams, dependent: :destroy
has_many :developers, through: :project_teams
has_many :project_time_sheets

has_many :active_developer_project, -> { where status: true,  most_recent_data: true }, class_name: 'ProjectTeam'
has_many :active_developers, :through => :active_developer_project, class_name: 'Developer', :source => :developer





validates :name, presence: true

default_scope { order("priority ASC") }

  def show_current_team
    ProjectTeam.where('project_id = ? and most_recent_data = true and status = true', self.id)
  end
end
