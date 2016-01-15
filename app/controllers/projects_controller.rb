class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :update_developers_percentage, :team_activity]

  #DELETING THE SESSION VALUES FOR DEVELOPERS PAGE, SO THAT USER SEES THE
  #DEFAULT PAGINATION OPTIONS IF HE NAVIGATES BACK
  before_action :reset_developer_session_values

  skip_before_action :verify_authenticity_token
  skip_before_filter :check_super_admin
  respond_to :html

  def index

    #DELETING SESSION VALUES FOR THE PROJECT ASSIGN PAGE
    reset_project_assign_session_values

    #SHOWING ACTIVE AND INACTIVE PROJECTS
    if params[:all] == 'true'

      #SORTING PROJECTS BASED ON PRIORITY
      @projects = Project.order(:priority, :id)

      #IF USER SELECTS A RESULT PER PAGE OPTION, THE SESSION VALUE FOR THIS IS STORED AND THE PAGE NUMBER IS RESET
      if params[:per_page]
        session[:project_index_for_all] = params[:per_page]

        #IF PAGE NUMBER IS NOT SET TO 1 AFTER NEW OPTION, IT MIGHT CAUSE UNEXPECTED RESULT
        #FOR EXAMPLE, IF YOU WERE IN PAGE 2 WITH 10 RESULTS PER PAGE, THEN IF YOU SELECT ALL RESULTS PER PAGE,
        #IT WILL BE EMPTY BECAUSE THERE IS NO PAGE 2
        session[:project_index_page_number_for_all] = 1
      end

      #THE CURRENT PAGE NUMBER WHERE THE USER IS NOW IS STORED
      session[:project_index_page_number_for_all] = params[:page] if params[:page]

      #THE PAGINATION FOR ALL PROJECTS BASED ON THE SESSION VALUES
      if session[:project_index_for_all]
        if session[:project_index_for_all] == "All"
          @projects = @projects.paginate(:per_page => @projects.count, :page => params[:page])
        else
          @projects = @projects.paginate(:per_page => session[:project_index_for_all],
                                         :page => session[:project_index_page_number_for_all])
        end
      else
        #IF THERE IS NO SESSION VALUE, THE PAGINATION IS DEFAULT TO 10
        @projects = @projects.paginate(:per_page => 10, :page => params[:page])
      end

    #ONLY the active projects are shown
    else

      @projects = Project.where(active: true).order(:priority, :id)

      #IF USER SELECTS A RESULT PER PAGE OPTION, THE SESSION VALUE FOR THIS IS STORED AND THE PAGE NUMBER IS RESET
      if params[:per_page]
        session[:project_index] = params[:per_page]

        #IF PAGE NUMBER IS NOT SET TO 1 AFTER NEW OPTION, IT MIGHT CAUSE UNEXPECTED RESULT
        #FOR EXAMPLE, IF YOU WERE IN PAGE 2 WITH 10 RESULTS PER PAGE, THEN IF YOU SELECT ALL RESULTS PER PAGE,
        #IT WILL BE EMPTY BECAUSE THERE IS NO PAGE 2
        session[:project_index_page_number] = 1
      end

      #THE CURRENT PAGE NUMBER WHERE THE USER IS NOW IS STORED
      session[:project_index_page_number] = params[:page] if params[:page]

      #THE PAGINATION FOR ACTIVE DEVELOPERS BASED ON THE SESSION VALUES
      if session[:project_index]
        if session[:project_index] == "All"
          @projects = @projects.paginate(:per_page => @projects.count, :page => params[:page])
        else
          @projects = @projects.paginate(:per_page => session[:project_index], :page => session[:project_index_page_number])
        end
      else
        #IF THERE IS NO SESSION VALUE, THE PAGINATION IS DEFAULT TO 10
        @projects = @projects.paginate(:per_page => 10, :page => params[:page])
      end

    end
    @last_page = (Project.where(active: true).count.to_f / WillPaginate.per_page).ceil

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

    #DELETING SESSION VALUES FOR THE PROJECT INDEX PAGE
    reset_projects_session_values

    @projects = Project.where(active: true).order(:priority).all

    ##Paginating Projects

    ##Making sure params[:page] doesn't have a null or invalid value
    ##If this error checking isn't taken care of, adding developers to a project raises an error
    begin
      params[:page] = Integer(params[:page]) unless params[:page].nil?
    rescue
      # ignore conversion errors
      params[:page] = 1
    end

    if params[:per_page]
      session[:project_assign] = params[:per_page]

      session[:project_assign_page_number] = 1
    end

    session[:project_assign_page_number] = params[:page] if params[:page]

    if session[:project_assign]
      if session[:project_assign] == "All"
        @projects = @projects.paginate(:per_page => @projects.count, :page => params[:page])
      else
        @projects = @projects.paginate(:per_page => session[:project_assign], :page => session[:project_assign_page_number])
      end
    else
      @projects = @projects.paginate(:per_page => 10, :page => params[:page])
    end

  end

  def create_project_team
    @project_team = ProjectTeam.new(project_team_params)
    @project_team.status = ProjectTeam::STATUS[:assigned]
    @project_team.most_recent_data = true

    if @project_team.developer_id.present?
      developr = Developer.find(@project_team.developer_id)
        if developr.joining_date.present?
          if @project_team.status_date >= developr.joining_date
            if @project_team.save
              flash[:success] = 'New developer has been added'
            else
              flash[:error] = "Unable to add the developer without proper information #{@project_team.errors}"
            end
          else
            flash[:error] = 'Unable to add the developer. Project assigned date must be greater then or equal to developer joining date'
          end
      else
        flash[:error] = 'Unable to add the developer. Please select a start date'
      end
    else
      flash[:error] = 'Unable to add a developer. No developer available to add to this project'
    end


    authorize! :create, @project_team

    redirect_to project_assign_path(page: params[:page])
  end

  def update_project_team
    @project_team = ProjectTeam.find(params[:id])
    @project_team.participation_percentage = params[:percentage] if params[:percentage].present?
    @project_team.status_date = params[:date] if params[:date].present?

    if params[:status] == '1'
      compare_date = @project_team.developer.joining_date
      error_message = 'Assigned date must be greater that or equal to developer joining date'
    elsif params[:status] == '2'
      compare_date = ProjectTeam.get_developer_assign_date(@project_team.developer_id, @project_team.project_id)
      error_message = 'Re-assigned date must be greater that or equal to assigned date'
    else
      compare_date = ProjectTeam.get_developer_assign_date(@project_team.developer_id, @project_team.project_id)
      error_message = 'Remove date must be greater that or equal to assigned date'
    end

    status = @project_team.project_id
    if @project_team.status_date >= compare_date
      if @project_team.save
        flash[:success] = 'Assignment data updated success!'
      else
        flash[:error] = 'Assignment data updated fail!'
      end
    else
      flash[:error] = error_message
    end

     authorize! :create, @project_team

    respond_to do |format|
      format.json { render json: {status: status} }
    end
  end

  def dev_list
    project_id = params[:id]
    assigned_dev_id_list = ProjectTeam.project_recent_data(project_id).pluck(:developer_id)
    @developer_list = Developer.active.where.not(id: assigned_dev_id_list)

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
    developer = Developer.find(dev_id)
    project_team = ProjectTeam.new(project_id: project_id, developer_id: dev_id, participation_percentage: params[:developer_percentage], status: ProjectTeam::STATUS[:re_assigned], status_date: params[:edit_date], previous_participation_percentage: params[:previous_percentage])
    authorize! :create, project_team

    if project_team.status_date.present?
      if project_team.status_date >= ProjectTeam.get_developer_assign_date(dev_id, project_id)
        if project_team.save
          flash[:success] = 'Developer Percentage has been Updated'
        else
          flash[:error] = 'Developer Percentage Update fail'
        end
      else
        flash[:error] = 'Project re-assigned date must be greater than or equal to  developer assigned date'
      end
    else
      flash[:error] = 'Developer Start Date Update fail'
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
