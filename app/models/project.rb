class Project < ActiveRecord::Base
has_many :project_teams, dependent: :destroy
has_many :developers, through: :project_teams

has_many :active_developer_project, -> { where status: true }, class_name: 'ProjectTeam'
has_many :active_developers, :through => :active_developer_project, class_name: 'Developer', :source => :developer





validates :name, presence: true

default_scope { order("priority ASC") }

  def show_current_team
    ProjectTeam.where('status = true and project_id = ?', self.id)
  end
end
