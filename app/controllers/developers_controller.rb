class DevelopersController < ApplicationController
  before_action :set_developer, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @developers = Developer.all
    # respond_with(@developers)
    @developers = @developers.paginate(:page => params[:page])
  end

  def show
    if params[:assign_date].present?
      @teams = ProjectTeam.where('status_date <= ? and developer_id = ?', params[:assign_date], @developer.id).order(' status_date DESC')
    else
      @teams = ProjectTeam.where('developer_id = ?', @developer.id).order('status_date DESC')
    end
    @teams = @teams.paginate(:page => params[:page])
    respond_with(@developer)
  end

  def new
    @developer = Developer.new
    respond_with(@developer)
  end

  def edit
  end

  def create
    @developer = Developer.new(developer_params)
    if @developer.save
      flash[:success] = 'New Developer has been successfully created'
    end
    respond_with(@developer)
  end

  def update
    if @developer.update(developer_params)
      flash[:success] = 'Developer information has been updated'
    end
    respond_with(@developer)
  end

  def destroy
    project_teams = @developer.active_project_teams
      if project_teams.exists?
        flash[:error] = "#{@developer.name } is engage in project. We have to first remove his/her project."
      else
        @developer.destroy
        flash[:success] = 'Developer has been removed'
      end
    respond_with(@developer)
  end

  def unassign
    project_id = params[:project_id]
    remove_date = params[:date]
    dev_id = params[:id]
    new_project_team = ProjectTeam.new({ project_id: project_id, developer_id: dev_id, status_date: remove_date, status: ProjectTeam::STATUS[:removed], participation_percentage: 0, most_recent_data: true })

    respond_to do |format|
      if new_project_team.save
         status = dev_id
      else
        status = 0
      end
      format.js
      format.json{ render json: { status: status }}
    end
  end

  def edit_developers_percentage
    @project_team = ProjectTeam.where('project_id =? and developer_id = ? and status IN (1,2) and most_recent_data = true', params[:project_id], params[:dev_id]).first
    respond_to do |format|
      format.js
    end
  end

  def engagement_report
    @filter_date = params[:filter_date] || Time.now.strftime("%Y-%m-%d")
    @developers = Developer.all
    @developers = @developers.paginate(:page => params[:page])
  end

  private
    def set_developer
      @developer = Developer.find(params[:id])
    end

    def developer_params
      params.require(:developer).permit(:name, :designation, :joining_date, :previous_job_exp)
    end
end
