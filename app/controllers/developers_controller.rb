class DevelopersController < ApplicationController
  before_action :set_developer, only: [:show, :edit, :update, :destroy]

  #DELETING THE SESSION VALUES FOR PROJECTS PAGE, SO THAT USER SEES THE
  #DEFAULT PAGINATION OPTIONS IF HE NAVIGATES BACK
  before_action :reset_projects_session_values,
                :reset_project_assign_session_values

  skip_before_filter :check_super_admin

  respond_to :html

  def index

    #If all the developers including the not active developers are shown
    if params[:all]

      @developers = Developer.order(active: :desc)

      #IF USER SELECTS A RESULT PER PAGE OPTION, THE SESSION VALUE FOR THIS IS STORED AND THE PAGE NUMBER IS RESET
      if params[:per_page]
        session[:developer_index_for_all] = params[:per_page]

        #IF PAGE NUMBER IS NOT SET TO 1 AFTER NEW OPTION, IT MIGHT CAUSE UNEXPECTED RESULT
        #FOR EXAMPLE, IF YOU WERE IN PAGE 2 WITH 10 RESULTS PER PAGE, THEN IF YOU SELECT ALL RESULTS PER PAGE,
        #IT WILL BE EMPTY BECAUSE THERE IS NO PAGE 2
        session[:developer_index_page_number_for_all] = 1
      end

      #THE CURRENT PAGE NUMBER WHERE THE USER IS NOW IS STORED
      session[:developer_index_page_number_for_all] = params[:page] if params[:page]

      #THE PAGINATION FOR ALL DEVELOPERS BASED ON THE SESSION VALUES
      if session[:developer_index_for_all]
        if session[:developer_index_for_all] == "All"
          @developers = @developers.paginate(:per_page => @developers.count, :page => params[:page])
        else
          @developers = @developers.paginate(:per_page => session[:developer_index_for_all],
                                             :page => session[:developer_index_page_number_for_all])
        end
      else
        #IF THERE IS NO SESSION VALUE, THE PAGINATION IS DEFAULT TO 10
        @developers = @developers.paginate(:per_page => 10, :page => params[:page])
      end

    #ONLY the active developers are shown
    else

      @developers = Developer.where(active: true).all

      #IF USER SELECTS A RESULT PER PAGE OPTION, THE SESSION VALUE FOR THIS IS STORED AND THE PAGE NUMBER IS RESET
      if params[:per_page]
        session[:developer_index] = params[:per_page]

        #IF PAGE NUMBER IS NOT SET TO 1 AFTER NEW OPTION, IT MIGHT CAUSE UNEXPECTED RESULT
        #FOR EXAMPLE, IF YOU WERE IN PAGE 2 WITH 10 RESULTS PER PAGE, THEN IF YOU SELECT ALL RESULTS PER PAGE,
        #IT WILL BE EMPTY BECAUSE THERE IS NO PAGE 2
        session[:developer_index_page_number] = 1
      end

      #THE CURRENT PAGE NUMBER WHERE THE USER IS NOW IS STORED
      session[:developer_index_page_number] = params[:page] if params[:page]

      #THE PAGINATION FOR ACTIVE DEVELOPERS BASED ON THE SESSION VALUES
      if session[:developer_index]
        if session[:developer_index] == "All"
          @developers = @developers.paginate(:per_page => @developers.count, :page => params[:page])
        else
          @developers = @developers.paginate(:per_page => session[:developer_index], :page => session[:developer_index_page_number])
        end
      else
        #IF THERE IS NO SESSION VALUE, THE PAGINATION IS DEFAULT TO 10
        @developers = @developers.paginate(:per_page => 10, :page => params[:page])
      end

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

    #PAGE PER RESULT OPTION FOR " DEVELPOPER ENGAGEMENT REPORT" STORED IN SESSION
    if params[:per_page]
      session[:developer_engagement] = params[:per_page]

      #IF PAGE NUMBER IS NOT SET TO 1 AFTER NEW OPTION, IT MIGHT CAUSE UNEXPECTED RESULT
      #FOR EXAMPLE, IF YOU WERE IN PAGE 2 WITH 10 RESULTS PER PAGE, THEN IF YOU SELECT ALL RESULTS PER PAGE,
      #IT WILL BE EMPTY BECAUSE THERE IS NO PAGE 2
      session[:developer_engagement_page_number] = 1
    end

    #THE CURRENT PAGE NUMBER IS ALSO STORED FOR LATER
    session[:developer_engagement_page_number] = params[:page] if params[:page]

    #ACTIVE DEPELOPERS PAGINATED BASED ON SESSION VALUES
    if session[:developer_engagement]
      if session[:developer_engagement] == "All"
        @developers = @developers.paginate(:per_page => @developers.count, :page => params[:page])
      else
        @developers = @developers.paginate(:per_page => session[:developer_engagement], :page => session[:developer_engagement_page_number])
      end
    else
      #DEFAULT PAGINATION TO 10 RESULTS PER PAGE INCASE THERE IS NO SESSION VALUE
      @developers = @developers.paginate(:per_page => 10, :page => params[:page])
    end

  end

  private
  def set_developer
    @developer = Developer.find(params[:id])
  end

  def developer_params
    params.require(:developer).permit(:name, :designation, :joining_date, :previous_job_exp, :active)
  end

end
