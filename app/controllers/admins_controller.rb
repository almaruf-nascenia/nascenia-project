class AdminsController < ApplicationController
   before_filter :check_super_admin, only: [:manage_admin_and_users_list, :make_user_admin, :remove_user_from_admin]

  respond_to :html, :js

  def manage_admin_and_users_list
    @admins = User.where(admin: true)
    @admins = @admins.paginate(:page => params[:admin_pagination])

    @users = User.where(admin: false)
    @users = @users.paginate(:page => params[:user_pagination])
  end

  def make_user_admin
    @user = User.find(params[:id])
    @user.admin = true
    @user.save

    respond_to do |format|
      format.js {}
    end
  end

  def remove_user_from_admin
    @user = User.find(params[:id])
    @user.admin = false
    @user.save
  end

  private

  def check_super_admin
      current_user.super_admin?
  end
end