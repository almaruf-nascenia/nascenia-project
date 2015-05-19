class ProjectTeam < ActiveRecord::Base
belongs_to :project
belongs_to :developer
validates :developer_id, presence: true
validates :start_date, presence: true

end
