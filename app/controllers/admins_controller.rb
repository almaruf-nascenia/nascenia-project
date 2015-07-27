class AdminsController < ApplicationController
  # before_action :set_developer, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def manage
    @admins = User.where(admin: true)
    @users = User.all
  end
end