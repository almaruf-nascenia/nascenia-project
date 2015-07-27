class AdminsController < ApplicationController
  # before_action :set_developer, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def manage_admin_and_users_list
    @admins = User.where(admin: true)
    @admins = @admins.paginate(:page => params[:admin_pagination])

    @users = User.all
    @users = @users.paginate(:page => params[:user_pagination])
  end
end