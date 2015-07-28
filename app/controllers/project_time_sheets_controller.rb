class ProjectTimeSheetsController < ApplicationController
  before_action :set_project_time_sheet, only: [:show, :edit, :update, :destroy]
  skip_before_filter :check_super_admin

  respond_to :html

  def index
    @project = Project.find(params[:project_id])
    @project_time_sheets = @project.project_time_sheets
    @project_time_sheets = @project_time_sheets.paginate(:page => params[:page])
    respond_with(@project_time_sheets)
  end

  def show
    @project = Project.find(params[:project_id])
    respond_with(@project_time_sheet)
  end

  def new
    @project = Project.find(params[:project_id])
    @project_time_sheet = ProjectTimeSheet.new(project: @project)
    respond_with(@project_time_sheet)
  end

  def edit
    @project = Project.find(params[:project_id])
    @project_time_sheet = ProjectTimeSheet.find(params[:id])
  end

  def create
    @project_time_sheet = ProjectTimeSheet.new(project_time_sheet_params)

    if @project_time_sheet.save
      flash[:notice] = 'New item successfully created'
      redirect_to(project_project_time_sheet_path( id: @project_time_sheet.id, project_id: @project_time_sheet.project_id ))
    else
      flash[:error] = 'Save reject'
      redirect_to(new_project_project_time_sheet_path)
    end

end

  def update
    @project_time_sheet.update(project_time_sheet_params)
    flash[:notice] = 'Time Sheet successfully updated'
    redirect_to(project_project_time_sheet_path( id: @project_time_sheet.id, project_id: @project_time_sheet.project_id ))
  end

  def destroy
    @project_time_sheet.destroy
    flash[:notice] = 'Time Sheet successfully deleted'
    redirect_to(project_project_time_sheets_path( id: @project_time_sheet.id, project_id: @project_time_sheet.project_id ))
  end

  private
    def set_project_time_sheet
      @project_time_sheet = ProjectTimeSheet.find(params[:id])
    end

    def project_time_sheet_params
      params.require(:project_time_sheet).permit(:Title, :Description, :Link, :project_id)
    end
end
