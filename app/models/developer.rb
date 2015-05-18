class Developer < ActiveRecord::Base
has_many :project_teams
has_many :projects, through: :project_teams
end
