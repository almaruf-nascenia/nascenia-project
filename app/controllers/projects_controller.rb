class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :update_developers_percentage]

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
    @project_team['status'] = true
    @project_team.most_recent_data = true
    if @project_team.save
      ProjectTeam.make_column_archive(@project_team.developer_id, @project_team.project_id, @project_team.id)
      flash[:success] = 'New developer has been added'
    else
      flash[:error] = "Unable to add the developer without proper information #{@project_team.errors}"
    end
    redirect_to project_assign_path
  end

  def dev_list
    project_id = params[:id]
    project = Project.find(project_id)
    project_dev = project.developers.where('most_recent_data = true and status = true')
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

  def update_developers_percentage
    dev_id = params[:dev_id]
    project_id = params[:id]
    if params[:developer_percentage].to_f > 0 and params[:developer_percentage].to_f <= 100
       project_team = ProjectTeam.where('project_id =? and developer_id = ? and status = true', params[:id], params[:dev_id]).order('id desc').first
       duplicate_project_team = project_team.dup
       duplicate_project_team.update_attributes(:participation_percentage => params[:developer_percentage])
       ProjectTeam.make_column_archive(dev_id, project_id, project_team.id)

       flash[:success] = 'Developer Percentage has been Updated'
    else
       flash[:error] = 'Developer Participation Percentage value should be between 0 to 100'
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
      params.permit(:project_id, :developer_id, :participation_percentage, :status_date)
    end
end
