class DevelopersController < ApplicationController
  before_action :set_developer, only: [:show, :edit, :update, :destroy]
  skip_before_filter :check_super_admin

  respond_to :html

  def index
    if params[:all]
      @developers = Developer.all
    else
      @developers = Developer.where(active: true).all
    end

    #@developers = @developers.paginate(:page => params[:page])
    ##Paginating Developers
    @per_page = params[:per_page] || 20
    if params[:per_page] == 'All'
      @developers = @developers.paginate(:per_page => @developers.count, :page => params[:page])
    else
      @developers = @developers.paginate(:per_page => @per_page, :page => params[:page])
    end



  end

  def show
    if params[:assign_date].present?
      @teams = ProjectTeam.where('status_date <= ? and developer_id = ?', params[:assign_date], @developer.id).order(' status_date DESC, id DESC')
    else
      @teams = ProjectTeam.where('developer_id = ?', @developer.id).order('status_date DESC, id DESC')
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
    authorize! :create, @developer

    respond_with(@developer)
  end

  def update
    if @developer.update(developer_params)
      flash[:success] = 'Developer information has been updated'
    end
    authorize! :update, @developer

    respond_with(@developer)
  end

  def destroy
    project_teams = @developer.active_project_teams
    if project_teams.exists?
      flash[:error] = "#{@developer.name } is assigned in project. To delete, you have to first unassigned him."
    else
      @developer.destroy
      flash[:success] = 'Developer has been removed'
    end
    authorize! :update, @developer

    respond_with(@developer)
  end

  def unassign
    project_id = params[:project_id]
    remove_date = params[:date]
    dev_id = params[:id]
    new_project_team = ProjectTeam.new({ project_id: project_id, developer_id: dev_id, status_date: remove_date, status: ProjectTeam::STATUS[:removed], participation_percentage: 0, most_recent_data: true })
    authorize! :create, new_project_team

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
    authorize! :create, @project_team

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
    params.require(:developer).permit(:name, :designation, :joining_date, :previous_job_exp, :active)
  end
end
