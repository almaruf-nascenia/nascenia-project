class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  #before_action :authenticate_user!
  respond_to :html

  def index
    @projects = Project.all
    respond_with(@projects)
  end

  def show
    if params[:assign_date].present?
      @teams = ProjectTeam.where('start_date <= ? and project_id = ?', params[:assign_date], @project.id)
    else
      @teams = ProjectTeam.where('project_id = ?', @project.id)
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
    @project.save
    respond_with(@project)
  end

  def update
    @project.update(project_params)
    respond_with(@project)
  end

  def destroy
    @project.destroy
    respond_with(@project)
  end

  def sort
    params[:order].each do |key,value|
      Project.find(value[:id]).update_attribute(:priority,value[:position])
    end
    render :nothing => true
  end

  def project_assign
    @projects = Project.all
    respond_with(@projects)
  end

  def create_project_team
    @project_team = ProjectTeam.new(project_team_params)
    @project_team['status'] = true
    @project_team.save
    redirect_to project_assign_path
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
