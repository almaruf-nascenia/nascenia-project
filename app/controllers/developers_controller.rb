class DevelopersController < ApplicationController
  before_action :set_developer, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @developers = Developer.all
    respond_with(@developers)
  end

  def show
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
    @developer.save
    respond_with(@developer)
  end

  def update
    @developer.update(developer_params)
    respond_with(@developer)
  end

  def destroy
    @developer.destroy
    respond_with(@developer)
  end

  private
    def set_developer
      @developer = Developer.find(params[:id])
    end

    def developer_params
      params.require(:developer).permit(:name, :designation, :joining_date, :previous_job_exp)
    end
end
