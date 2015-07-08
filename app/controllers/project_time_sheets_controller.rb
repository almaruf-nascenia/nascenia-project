class ProjectTimeSheetsController < ApplicationController
  before_action :set_project_time_sheet, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @project_time_sheets = ProjectTimeSheet.all
    respond_with(@project_time_sheets)
  end

  def show
    respond_with(@project_time_sheet)
  end

  def new
    @project_time_sheet = ProjectTimeSheet.new
    respond_with(@project_time_sheet)
  end

  def edit
  end

  def create
    @project_time_sheet = ProjectTimeSheet.new(project_time_sheet_params)
    @project_time_sheet.save
    respond_with(@project_time_sheet)
  end

  def update
    @project_time_sheet.update(project_time_sheet_params)
    respond_with(@project_time_sheet)
  end

  def destroy
    @project_time_sheet.destroy
    respond_with(@project_time_sheet)
  end

  private
    def set_project_time_sheet
      @project_time_sheet = ProjectTimeSheet.find(params[:id])
    end

    def project_time_sheet_params
      params.require(:project_time_sheet).permit(:Title, :Description, :Link)
    end
end
