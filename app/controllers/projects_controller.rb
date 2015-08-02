class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :update_developers_percentage, :team_activity]

  skip_before_action :verify_authenticity_token
  skip_before_filter :check_super_admin
  respond_to :html

  def index
    if params[:all] == 'true'
      @projects = Project.order(:priority, :id)
    else
      @projects = Project.where(active: true).order(:priority, :id)
    end
    @last_page = (Project.where(active: true).count.to_f / WillPaginate.per_page).ceil
    @projects = @projects.paginate(page: params[:page])
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
    authorize! :create, @project

    respond_with(@project)
  end

  def edit
    authorize! :update, @project

  end

  def create
    @project = Project.new(project_params)
    @project.priority = Project.where(active: true).count + 1
    if @project.save
      flash[:success] = 'Project has been successfully created'
    end
    authorize! :create, @project

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
    active_field_same_as_input = project_params[:active].present? && project_params[:active] == '1'

    if @project.active != active_field_same_as_input
        if project_params[:active] == '1'
          projects_to_be_updated = Project.where("priority < ? AND active = ? ", @project.priority, false)
          projects_to_be_updated.each do |project|
            Project.increment_counter(:priority, project.id)
          end
          new_priority = Project.where(active: true).count + 1
          @project.priority = new_priority
        elsif project_params[:active] == '0'
          projects_to_be_updated = Project.where("priority > ? AND active = ? ", @project.priority, true)
          projects_to_be_updated.each do |project|
            Project.decrement_counter(:priority, project.id)
          end
          new_priority = Project.where(active: true).count
          @project.priority = new_priority
        end
    end

    if @project.update(project_params)
      flash[:success] = 'Project information has been updated'
    end
    authorize! :update, @project

    respond_with(@project)
  end

  def destroy
    projects_to_be_updated = Project.where("priority > ? AND active = ? ", @project.priority, true)
    projects_to_be_updated.each do |project|
      Project.decrement_counter(:priority, project.id)
    end
    @project.destroy
    flash[:success] = 'Project has been removed'
    authorize! :delete, @project

    respond_with(@project)
  end

  def project_assign
    @projects = Project.where(active: true).order(:priority).all
    # respond_with(@projects)
    @projects = @projects.paginate(:page => params[:page])

  end

  def create_project_team
    @project_team = ProjectTeam.new(project_team_params)
    @project_team.status = ProjectTeam::STATUS[:assigned]
    @project_team.most_recent_data = true
    developr = Developer.find(@project_team.developer_id)
    if @project_team.status_date <= developr.joining_date
      if @project_team.save
        flash[:success] = 'New developer has been added'
      else
        flash[:error] = "Unable to add the developer without proper information #{@project_team.errors}"
      end
    else
      flash[:error] = "Project Assigned date must be >= developer joining date"
    end

    authorize! :create, @project_team

    redirect_to project_assign_path
  end

  def update_project_team
    @project_team = ProjectTeam.find(params[:id])
    @project_team.participation_percentage = params[:percentage] if params[:percentage].present?
    @project_team.status_date = params[:date] if params[:date].present?


    if @project_team.save
      flash[:success] = 'Assignment data updated'
    else
      flash[:error] = 'Assignment data updated'
    end

    status = params[:project_id]
    # authorize! :create, @project_team

    respond_to do |format|
      format.json { render json: {status: status} }
    end
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
    @developers = Developer.all
    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"project-activity-list.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  def update_developers_percentage
    dev_id = params[:dev_id]
    project_id = params[:id]
    project_team = ProjectTeam.new(project_id: project_id, developer_id: dev_id, participation_percentage: params[:developer_percentage], status: ProjectTeam::STATUS[:re_assigned], status_date: params[:edit_date], previous_participation_percentage: params[:previous_percentage])
    authorize! :create, project_team

    if project_team.save
      flash[:success] = 'Developer Percentage has been Updated'
    else
      flash[:error] = 'Developer Percentage Update fail'
    end
  end

  def team_activity
    project = Project.find(params[:id])
    @project_teams = project.project_teams.order('status_date DESC, id DESC')
    @project_teams = @project_teams.paginate(:page => params[:assignment_page])

    @team_members = ProjectTeam.project_recent_data(project.id)
    @team_members = @team_members.paginate(:page => params[:developer_page])
  end

  def update_table_priority
    project_ids = params[:project_ids]
    page_number = params[:page_number].present? ? params[:page_number].to_i : 1
    authorize! :update, Project
    project_ids.each_with_index do |project_id, index|
      Project.find(project_id).update_attributes(priority: WillPaginate.per_page  * ( page_number -1 )+ index + 1)
    end

    @projects = Project.order(:priority, :id).all
    @projects = @projects.paginate(page: params[:page_number].to_i)
    @page =  page_number
    @all = params[:all]

    respond_to do |format|
      format.js
    end
  end

  def project_table_row_up
    project_id = params[:id]
    project = Project.find(project_id)
    Project.find_by_priority(project.priority - 1).update_attribute(:priority, project.priority)
    project.update_attribute(:priority, project.priority - 1)

    @page = params[:page].present? ? params[:page].to_i : 1
    @projects = Project.order(:priority, :id).all
    @projects = @projects.paginate(page: @page)
    @all = params[:all]

    if Project.find(project_id).priority % WillPaginate.per_page == 0
      @page = @page - 1
    end

    respond_to do |format|
      format.js
    end
  end

  def project_table_row_down
    project_id = params[:id]
    project = Project.find(project_id)
    if project.priority != Project.count
      Project.find_by_priority(project.priority + 1).update_attribute(:priority, project.priority)
      project.update_attribute(:priority, project.priority + 1)

      @page = params[:page].present? ? params[:page].to_i : 1
      @projects = Project.order(:priority, :id).all
      @projects = @projects.paginate(page: @page)
      @all = params[:all]

      if Project.find(project_id).priority % WillPaginate.per_page == 1
        @page = @page + 1
      end
    else
      flash[:error] = "Can't Go Down More"
    end

    respond_to do |format|
      format.js
    end
  end

  private
  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:id, :name, :title, :description, :priority, :active)
  end

  def project_team_params
    params.permit(:project_id, :developer_id, :participation_percentage, :status_date)
  end
end
