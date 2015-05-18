class Project < ActiveRecord::Base
has_many :project_teams
has_many :developers, through: :project_teams
end
