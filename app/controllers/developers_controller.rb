class DevelopersController < ApplicationController
  before_action :set_developer, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @developers = Developer.all
    respond_with(@developers)
  end

  def show
    if params[:assign_date].present?
      @teams = ProjectTeam.where('start_date <= ? and developer_id = ?', params[:assign_date], @developer.id).order('end_date IS NOT NULL, end_date DESC')
    else
      @teams = ProjectTeam.where('developer_id = ?', @developer.id).order('end_date IS NOT NULL, end_date DESC')
    end
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
    developer = ProjectTeam.where('developer_id = ? and status = true', @developer.id)
      if developer.exists?
        flash[:error] = 'This developer can not be removed'
      else
        @developer.destroy
        flash[:success] = 'Developer has been removed'
      end
    respond_with(@developer)
  end

  def unassign
    project_id = params[:project_id]
    dev_id = params[:id]
    project_team = ProjectTeam.where('project_id =? and developer_id = ? and status = true', project_id, dev_id).first
    respond_to do |format|
      if project_team.present?
        project_team.status = false
        project_team.end_date = Time.now.strftime("%Y-%m-%d")
        project_team.save
        @status = 1
      else
        @status = 0
      end
      format.js
    end
  end

  private
    def set_developer
      @developer = Developer.find(params[:id])
    end

    def developer_params
      params.require(:developer).permit(:name, :designation, :joining_date, :previous_job_exp)
    end
end
