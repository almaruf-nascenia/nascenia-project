class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  skip_before_action :verify_authenticity_token
  respond_to :html

  def index
    @projects = Project.all
    respond_with(@projects)
  end

  def show
    if params[:assign_date].present?
      @teams = ProjectTeam.where('start_date <= ? and project_id = ?', params[:assign_date], @project.id).order('end_date IS NOT NULL, end_date DESC')
    else
      @teams = ProjectTeam.where('project_id = ?', @project.id).order('end_date IS NOT NULL, end_date DESC')
    end
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
    respond_with(@projects)
  end

  def create_project_team
    @project_team = ProjectTeam.new(project_team_params)
    @project_team['status'] = true
    if @project_team.save
      flash[:success] = 'New developer has been added'
    else
      flash[:error] = "Unable to add the developer without proper information #{@project_team.errors.inspect}"
    end
    redirect_to project_assign_path
  end

  def dev_list
    project_id = params[:id]
    project = Project.find_by_id(project_id)
    project_dev = project.developers.where('status = true')
    @developer_list = Developer.all - project_dev
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


  private
    def set_project
      @project = Project.find(params[:id])
    end

    def project_params
      params.require(:project).permit(:id, :name, :title, :description)
    end

    def project_team_params
      params.permit(:project_id, :developer_id, :participation_percentage, :start_date)
    end
end
