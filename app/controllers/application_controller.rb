class ApplicationController < ActionController::Base
  require 'csv'
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!, :check_super_admin

  private

  def check_super_admin
    current_user && current_user.super_admin?
  end
end
