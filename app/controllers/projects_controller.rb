class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :update_developers_percentage, :team_activity]

  skip_before_action :verify_authenticity_token
  respond_to :html

  def index
    @projects = Project.all
    # respond_with(@projects)
    # sc = ProjectTeam.select("CONCAT(project_id, '-', developer_id, '-', MAX(created_at))").group(:project_id, :developer_id)
    # pd = ProjectTeam.select('project_id = ? AND status = 1 AND CONCAT(project_id, '-', developer_id, '-', created_at) IN (?)', 2, sc)
    # pd.inspect

    @projects = @projects.paginate(:page => params[:page])
  end

  def show
    if params[:assign_date].present?
      @teams = ProjectTeam.where('status_date <= ? and project_id = ?', params[:assign_date], @project.id).order('status_date DESC')
    else
      @teams = ProjectTeam.where('project_id = ?', @project.id).order('status_date DESC')
    end
    @teams = @teams.paginate(:page => params[:page])
    respond_with(@project)
  end

  def new
    @project = Project.new
    respond_with(@project)
  end

  def edit
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      flash[:success] = 'Project has been successfully created'
    end
    respond_with(@project)
  end

  def sortable
    updated_order = params[:order]
    updated_order.each_with_index do |id, index|
      project = Project.find_by_id(id)
      project.priority = index
      project.save
    end
  end

  def update
    if @project.update(project_params)
      flash[:success] = 'Project information has been updated'
    end

    respond_with(@project)
  end

  def destroy
    @project.destroy
    flash[:success] = 'Project has been removed'
    respond_with(@project)
  end

  def project_assign
    @projects = Project.order(priority: :desc).all
    # respond_with(@projects)
    @projects = @projects.paginate(:page => params[:page])

  end

  def create_project_team
    @project_team = ProjectTeam.new(project_team_params)
    @project_team.status = ProjectTeam::STATUS[:assigned]
    @project_team.most_recent_data = true
    if @project_team.save
      flash[:success] = 'New developer has been added'
    else
      flash[:error] = "Unable to add the developer without proper information #{@project_team.errors}"
    end
    redirect_to project_assign_path
  end

  def dev_list
    project_id = params[:id]
    assigned_dev_id_list = ProjectTeam.project_recent_data(project_id).pluck(:developer_id)
    @developer_list = Developer.where.not(id: assigned_dev_id_list)

    respond_to do |format|
      format.js
    end
  end

  def export
    @projects= Project.all
    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"project-activity-list\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def update_developers_percentage
    dev_id = params[:dev_id]
    project_id = params[:id]
    update_project_team = ProjectTeam.new(project_id: project_id, developer_id: dev_id, participation_percentage: params[:developer_percentage], status: ProjectTeam::STATUS[:re_assigned], status_date: params[:edit_date] )

    if update_project_team.save
       flash[:success] = 'Developer Percentage has been Updated'
    else
       flash[:error] = update_project_team.errors.full_messages.first
    end
  end

  def team_activity
    @project_teams = @project.project_teams.order('status_date, id DESC')
    @project_teams = @project_teams.paginate(:page => params[:page])
  end

  private
    def set_project
      @project = Project.find(params[:id])
    end

    def project_params
      params.require(:project).permit(:id, :name, :title, :description)
    end

    def project_team_params
      params.permit(:project_id, :developer_id, :participation_percentage, :status_date)
    end
end
